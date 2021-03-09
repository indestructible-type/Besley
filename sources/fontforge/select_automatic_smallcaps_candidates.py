#!/usr/bin/env python3

# If you have a font that you've already added A-Z smallcaps to, and it has a bunch of precombined characters (e.g. İ, Ĵ, Ṡ, Ẅ), this script will select candidates for automatic building of precombined small caps via «Element→Style→Add Small Capitals…» in FontForge.

# This is meant to be run in the UI through the "Execute Script" dialog.

import fontforge
import unicodedata
import sys
import string

f = fontforge.activeFont()
f.selection.none()

def decompose(udd):
    if any(["<" in c for c in udd]):
        return []
    r = [chr(int(c, 16)) for c in udd.split()]
    return r

to_select = list()
for g in f.glyphs():
    try:
        u = chr(g.unicode)
    except ValueError:
        continue
    c = unicodedata.category(u)
    d = decompose(unicodedata.decomposition(u))
    if not c.startswith("L"):
        continue
    if u.upper() == u and len(d) > 0 and d[0] in string.ascii_uppercase:
        to_select.append(g)

f.selection.select(*to_select, ("more",))
