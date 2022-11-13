# SFD normalizer (discards GUI information from SFD files)
# For authors, see AUTHORS.
#
# usage: ./sfdnormalize sfd_file(s)
#  will rewrite files in place

# changes done:
#   SplineFontDB - fix version number on 3.0
#   WinInfo - discarded
#   DisplaySize - discarded
#   AntiAlias - discarded
#   FitToEm - discarded
#   Compacted - discarded
#   GenTags - discarded
#   Copyright - discarded
#   Flags   - discarded O (open), H (changed since last hinting - often irrelevant)
#   Refer   - changed S (selected) to N (not selected)
#   Fore, Back, SplineSet, Grid
#           - all points have 0x4 masked out from flags (selected)
#           - TrueType curve points dropped
#           - hint masks dropped
#   ModificationTime - discarded
#   Validated - discarded
#   Empty glyph positions dropped
#   Hinting dropped
#   End-of-line whitespace dropped

# !!! Always review changes done by this utility !!!

from __future__ import print_function

from collections import OrderedDict
from typing import Optional, List

from . import *

import argparse
import io, sys, re

import sfdutf7

fealines_tok = '__X_FEALINES_X__'

DROPPED = [
    "WinInfo", "DisplaySize", "AntiAlias", "FitToEm", "Compacted", "GenTags",
    "ModificationTime", "DupEnc", "Copyright"
]

drop_regex = lambda extra: "^(" + "|".join(DROPPED + extra) + ")"

FONT_RE = re.compile(r"^SplineFontDB:\s(\d+\.?\d*)")
DROP_RE = re.compile(drop_regex([]))
SPLINESET_RE = re.compile(r"^(Fore|Back|SplineSet|Grid)\s*$")
BACK_RE = re.compile(r"^Back$")
STARTCHAR_RE = re.compile(r"^StartChar:\s*(\S+)\s*$")
ENCODING_RE = re.compile(r"^Encoding:\s*(\-?\d+)\s+(\-?\d+)\s*(\d*)\s*$")
BITMAPFONT_RE = re.compile(r"^(BitmapFont:\s+\d+\s+)(\d+)(\s+\d+\s+\d+\s+\d+)")
BDFCHAR_RE = re.compile(r"^BDFChar:\s*(\d+)(\s+.*)$")
EMPTY_FLAGS_RE = re.compile(r"^Flags:\s*$")
DROP_FLAGS_RE = re.compile(r"^(Flags:.*?)[HO](.*)$")
POINT_RE = re.compile(r"(\s+[mcl]+?\s)(\d+)(\s*)(,-?\d+,-?\d+)?(x.*.)?$")
SELECTED_REF_RE = re.compile(r"(-?\d+\s+)S(\s+-?\d+)")
OTFFEATNAME_RE = re.compile(r"OtfFeatName:\s*'(....)'\s*(\d+)\s*(.*)$")
HINTS_RE = re.compile(r"^[HVD]Stem2?: ")
FEASUBPOS_RE = re.compile(r"^(Position|PairPos|LCarets|Ligature|Substitution|MultipleSubs|AlternateSubs)2?:")
FLOAT_REGEX = r"([-+]?(?:(?:\d*\.\d+)|\d+))"
ANCHORPOINT_RE = re.compile(fr"""^AnchorPoint:\s*("[^"]*")\s*{FLOAT_REGEX}\s*{FLOAT_REGEX}\s*([a-z0-9]+)\s*(\d+)$""")

fealine_order = {'Position': 1, 'PairPos': 2, 'LCarets': 3, 'Ligature': 4,
                 'Substitution': 5, 'MultipleSubs': 6, 'AlternateSubs': 7 }

# The following class is used to emulate variable assignment in
# conditions: while testing if a pattern corresponds to a specific
# regular expression we also preserve the 'match' object for future use.
class RegexpProcessor:
    def test(self, cp, string):
        self.m = cp.search(string)
        return not(self.m is None)

    def match(self):
        return self.m

def normalize_point(m):
    pt = int(m.group(2)) & ~0x4;
    return m.group(1) + str(pt) + m.group(3)

def should_drop(proc: RegexpProcessor, fl: str, keep: Optional[List[str]] = None) -> bool:
    return proc.test(DROP_RE, fl) and (keep == None or not any([fl.startswith(k) for k in keep]))

def process_sfd_file(args):
    sfdname = args.input_file
    outname = args.output_file
    fp = open(sfdname, 'rt')

    if args.replace:
        out = io.StringIO()
    else:
        out = open(outname, 'wt')

    fl = fp.readline()
    proc = RegexpProcessor()

    if proc.test(FONT_RE, fl) == False:
        print("%s is not a valid spline font database" % sfdname)
        return

    out.write("SplineFontDB: {}\n".format(args.sfd_version))

    curglyph = ''
    cur_gid = 0
    in_spline_set = False
    max_dec_enc = 0
    max_unicode = 0
    new_gid = 0
    in_chars = False
    in_bdf = False
    bmp_header = ()
    bdf = OrderedDict()
    glyphs = OrderedDict()
    feat_names = {}

    fl = fp.readline()
    while fl:
        if should_drop(proc, fl, keep=args.keep):
            fl = fp.readline()
            continue

        elif in_chars:
            # Cleanup glyph flags
            fl = DROP_FLAGS_RE.sub(r"\1\2", fl)
            fl = DROP_FLAGS_RE.sub(r"\1\2", fl)

            # If we have removed all previously specified glyph flags,
            # then don't output the "Flags" line for this glyph
            if proc.test(EMPTY_FLAGS_RE, fl):
                fl = fp.readline()
                continue

        fl = fl.replace(' \n', '\n')

        if proc.test(SPLINESET_RE, fl):
            in_spline_set = True;

        elif fl.startswith("EndSplineSet"):
            in_spline_set = False;

        elif (in_spline_set):
            # Deselect selected points
            fl = POINT_RE.sub(normalize_point, fl)

        if fl.startswith("BeginChars:"):
            in_chars = True;

        elif fl.startswith("EndChars"):
            in_chars = False;

            out.write("BeginChars: %s %s\n" % (max_dec_enc + 1, len(glyphs)))

            for glyph in glyphs.values():
                if glyph["dec_enc"] < 0: # GitHub issue alerque/sfdnormalize#3
                    continue
                out.write("\n")
                out.write("StartChar: %s\n" % glyph['name'])
                out.write("Encoding: %s %s %s\n" % (glyph["dec_enc"], glyph['unicode'], glyph["gid"]))

                glyph_lines = iter(glyph['lines'])
                skip_lines = 0
                for gl in glyph_lines:
                    if skip_lines > 0:
                        skip_lines -= 1
                        continue
                    if should_drop(proc, gl, keep=args.keep):
                        continue
                    if gl.startswith("Refer: "):
                        # deselect selected references
                        gl = SELECTED_REF_RE.sub(r"\1N\2", gl)
                    elif gl.endswith(" [ddx={} ddy={} ddh={} ddv={}]\n"):
                        gl = gl.replace(" [ddx={} ddy={} ddh={} ddv={}]", "")
                    elif gl == fealines_tok:
                        for (flt, fll) in sorted(glyph['fealines']):
                            out.write(fll)
                        continue
                    elif proc.test(HINTS_RE, gl):
                        continue
                    elif gl.startswith("Validated:"):
                        continue
                    elif proc.test(ANCHORPOINT_RE, gl):
                        anchorpoints = list()
                        skip_lines -= 1
                        for ggl in glyph['lines']:
                            if proc.test(ANCHORPOINT_RE, ggl):
                                skip_lines += 1
                                matched = proc.match().groups()
                                anchorpoints.append(list(matched))
                        for i, ap in enumerate(anchorpoints, start=0):
                            ap[0] = sfdutf7.decode(ap[0].encode('ascii'), unquote=True)
                            anchorpoints[i] = tuple(ap)
                        anchorpoints_d = {ap[0]: dict() for ap in anchorpoints}
                        for ap in anchorpoints:
                            anchorpoints_d[ap[0]] = ap[1:]
                        for ap in sorted(set(anchorpoints_d.keys())):
                            out.write("AnchorPoint: %s %s\n" %
                                      (sfdutf7.encode(ap,
                                                      quote=True).decode('ascii'),
                                       " ".join(anchorpoints_d[ap])))

                        continue

                    out.write(gl)
                out.write("EndChar\n")

            out.write("EndChars\n")

        elif proc.test(STARTCHAR_RE, fl):
            curglyph = proc.match().group(1)
            glyph = { 'name' : curglyph, 'lines' : [] , 'fealines': [] }

            while curglyph in glyphs:
                curglyph = curglyph + '#'

            glyphs[curglyph] = glyph

        elif proc.test(ENCODING_RE, fl):
            dec_enc = int(proc.match().group(1))
            unicode_enc = int(proc.match().group(2))
            gid = int(proc.match().group(3))

            max_dec_enc = max(max_dec_enc, dec_enc)
            max_unicode = max(max_unicode, unicode_enc)

            glyphs[curglyph]['dec_enc'] = dec_enc;
            glyphs[curglyph]['unicode'] = unicode_enc;
            glyphs[curglyph]['gid'] = gid;

        elif proc.test(FEASUBPOS_RE, fl):
            fea_type = proc.match().group(1)
            if len(glyphs[curglyph]['fealines']) == 0:
                glyphs[curglyph]['lines'].append(fealines_tok)
            glyphs[curglyph]['fealines'].append((fealine_order.get(fea_type, 0), fl))

        elif fl.startswith("EndChar"):
            curglyph = '';

        elif proc.test(BITMAPFONT_RE, fl):
            in_bdf = True;
            bdf_header = (proc.match().group(1), str(len(glyphs)), proc.match().group(3))

        elif fl.startswith("EndBitmapFont"):
            out.write(''.join(bdf_header) + "\n")
            max_bdf = int(bdf_header[1])
            for gid in range(0, max_bdf):
                if gid in bdf:
                    for bdfl in bdf[gid]['lines']:
                        out.write(bdfl)

            out.write("EndBitmapFont\n")
            in_bdf = False;
            bdf = {}
            bdf_header = ()

        elif proc.test(BDFCHAR_RE, fl):
            cur_gid = int(proc.match().group(1))
            bdf_char = { 'gid' : cur_gid, 'lines' : [] }
            bdf_char['lines'].append("BDFChar: " + str(cur_gid) + proc.match().group(2) + "\n")
            bdf[cur_gid] = bdf_char

        elif proc.test(OTFFEATNAME_RE, fl):
            while proc.test(OTFFEATNAME_RE, fl):
                tag, lang, name = proc.match().groups()
                feat_names[(tag, lang)] = name
                fl = fp.readline()
            for feat in sorted(feat_names):
                out.write("OtfFeatName: '%s' %s %s\n" % (feat[0], feat[1], feat_names[feat]))
            continue

        else:
            if not in_chars and not in_bdf:
                out.write(fl);
            elif in_chars and curglyph != '':
                glyphs[curglyph]['lines'].append(fl)
            elif in_bdf and cur_gid in bdf:
                bdf[cur_gid]['lines'].append(fl)

        fl = fp.readline()

    fp.close()

    if args.replace:
        out.seek(0)
        to_write = out.read()
        out = open(sfdname, "wt+")
        out.write(to_write)

    out.close()

# Program entry point
def main():
    argparser = argparse.ArgumentParser(description="Normalize Spline Font Database (SFD) files", prog=__package__, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    argparser.add_argument("input_file", help="Input SFD before normalization")
    argparser.add_argument("output_file", help="Path to write normalized SFD", nargs="?")

    argparser.add_argument("--replace", "-r", help="Replace in place", action="store_true")
    argparser.add_argument("--version", "-V", action="version", version="%(prog)s {}".format(VERSION_STR))
    argparser.add_argument("--keep", "-k", help="Keep lines beginning with these even if they'd be normally dropped. (Can provide multiple times.)", action="append")
    argparser.add_argument("--drop", "-D", help="Drop lines beginning with these even if they'd be normally kept. (Can provide multiple times.)", action="append")
    argparser.add_argument("--sfd-version", "-s", help="By default, latest SFD revision known to this program will be written, unless specified here", default=SFD_VERSION_STR, metavar="VERSION")

    # Note [len('usage: '):] hack is removeprefix("usage: ") from Python 3.9+, cleanup if we ever require new Python for something else
    argparser.usage = argparser.format_usage()[len('usage: '):].rstrip() + "\nhttps://github.com/alerque/sfdnormalize\n(For authors, see AUTHORS in source distribution.)"
    args = argparser.parse_args()

    if args.drop and len(args.drop) > 0:
        global DROP_RE
        DROP_RE = re.compile(drop_regex(args.drop))

    if not args.output_file and not args.replace:
        argparser.error(message="Must provide either a file to output to or -r")

    process_sfd_file(args)

if __name__ == '__main__':
    main()
