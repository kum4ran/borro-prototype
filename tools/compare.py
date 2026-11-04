#!/usr/bin/env python3
"""Side-by-side Figma render vs app screenshot for every captured artboard.

    python3 tools/compare.py            # all that exist
    python3 tools/compare.py 691-4767   # specific slugs
"""
import json
import os
import sys
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIGMA = os.path.join(ROOT, "design", "figma", "frames")
SHOTS = os.path.join(ROOT, "docs", "screens", "qa")
OUT = os.path.join(ROOT, "docs", "screens", "compare")
os.makedirs(OUT, exist_ok=True)

idx = json.load(open(os.path.join(ROOT, "design", "figma", "frames", "index.json")))
slugs = [f for s in idx["sections"] for f in s["frames"]]
if len(sys.argv) > 1:
    slugs = [s for s in slugs if any(a in s for a in sys.argv[1:])]

TARGET_H = 900
made = 0
for slug in slugs:
    design_path = os.path.join(FIGMA, f"{slug}.png")
    shot_path = os.path.join(SHOTS, f"{slug}.png")
    if not (os.path.exists(design_path) and os.path.exists(shot_path)):
        continue
    design = Image.open(design_path).convert("RGB")
    shot = Image.open(shot_path).convert("RGB")

    def fit(im):
        w = int(im.width * TARGET_H / im.height)
        return im.resize((w, TARGET_H), Image.LANCZOS)

    d, s = fit(design), fit(shot)
    label = 34
    canvas = Image.new("RGB", (d.width + s.width + 30, TARGET_H + label), (240, 242, 246))
    canvas.paste(d, (10, label))
    canvas.paste(s, (d.width + 20, label))
    draw = ImageDraw.Draw(canvas)
    draw.text((10, 10), f"{slug}  ·  Figma", fill=(20, 35, 28))
    draw.text((d.width + 20, 10), "SwiftUI", fill=(20, 35, 28))
    canvas.save(os.path.join(OUT, f"{slug}.jpg"), quality=82)
    made += 1

print(f"wrote {made} comparisons to docs/screens/compare/")
