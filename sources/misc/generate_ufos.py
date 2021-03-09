#!/usr/bin/env python3

import fontforge

FONTS = {
    "fontforge/Book.sfd": "UFO/Besley-Regular.ufo",
#   "fontforge/Book Italic.sfd": "UFO/Besley-Italic.ufo",
    "fontforge/Fatface.sfd": "UFO/Besley-Black.ufo",
#   "fontforge/Fatface Italic.sfd": "UFO/Besley-Italic.ufo"
}

ARGS = ("opentype","no-hints","omit-instructions")

for sfd, ufo in FONTS.items():
    f = fontforge.open(sfd)
    f.generate(ufo, flags=ARGS)
