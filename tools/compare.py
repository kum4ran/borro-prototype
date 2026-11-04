#!/usr/bin/env python3
"""Side-by-side: Figma render (left) and simulator screenshot (right), same height."""
import sys
from PIL import Image
H = 852
for code in sys.argv[1:]:
    try:
        fig = Image.open(f"design/prototype/png/{code}.png").convert("RGB")
        app = Image.open(f"Docs/screens/app/{code}.png").convert("RGB")
    except FileNotFoundError:
        continue
    fig = fig.resize((round(fig.width * H / fig.height), H))
    app = app.resize((round(app.width * H / app.height), H))
    out = Image.new("RGB", (fig.width + app.width + 12, H), "white")
    out.paste(fig, (0, 0)); out.paste(app, (fig.width + 12, 0))
    out.save(f"Docs/screens/compare/{code}.png")
