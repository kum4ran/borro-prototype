#!/usr/bin/env python3
"""Tile compare images for quick review: python3 tools/montage.py out.png 2.1 2.2 ..."""
import sys
from PIL import Image
out, codes = sys.argv[1], sys.argv[2:]
ims = [Image.open(f"Docs/screens/compare/{c}.jpg") for c in codes]
scale = float(__import__("os").environ.get("SCALE", "0.5"))
ims = [i.resize((int(i.width * scale), int(i.height * scale))) for i in ims]
w = sum(i.width for i in ims) + 8 * (len(ims) - 1)
o = Image.new("RGB", (w, max(i.height for i in ims)), "white")
x = 0
for i in ims:
    o.paste(i, (x, 0)); x += i.width + 8
o.save(out)
