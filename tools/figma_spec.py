#!/usr/bin/env python3
"""Write a compact, readable spec per Prototype frame: design/prototype/spec/<code>.txt

Usage: python3 tools/figma_spec.py <proto.json>
Each line: indent by depth, kind, frame-relative x,y w×h, then style and text.
"""
import json, os, sys

def hexc(c, o=1):
    a = c.get("a", 1) * o
    h = "#%02X%02X%02X" % tuple(round(c[k] * 255) for k in "rgb")
    return h if a >= 0.999 else f"{h}@{a:.2f}"

def fills(n):
    out = []
    for f in n.get("fills") or []:
        if f.get("visible") is False: continue
        if f["type"] == "SOLID": out.append(hexc(f["color"], f.get("opacity", 1)))
        elif f["type"] == "IMAGE": out.append("img:" + (f.get("imageRef") or "")[:10] + ":" + f.get("scaleMode", ""))
        elif f["type"].startswith("GRADIENT"): out.append("grad(" + ",".join(hexc(s["color"]) for s in f.get("gradientStops", [])) + ")")
    return out

def main(src):
    page = json.load(open(src))["nodes"]["377:1195"]["document"]
    os.makedirs("design/prototype/spec", exist_ok=True)
    for s in page["children"]:
        if s["type"] != "SECTION" or s["name"].startswith("Countdown"): continue
        for f in s.get("children", []):
            if f["type"] != "FRAME": continue
            ox, oy = f["absoluteBoundingBox"]["x"], f["absoluteBoundingBox"]["y"]
            lines = [f"# {f['name']}  ({f['id']})  section: {s['name']}"]
            def walk(n, d):
                if n.get("visible") is False: return
                b = n.get("absoluteBoundingBox") or {}
                geo = "%d,%d %dx%d" % (round(b.get("x", 0) - ox), round(b.get("y", 0) - oy), round(b.get("width", 0)), round(b.get("height", 0)))
                parts = [n["type"][:4], repr(n["name"][:40]), geo]
                fl = fills(n)
                if fl: parts.append("fill=" + "|".join(fl))
                st = [hexc(x["color"]) for x in n.get("strokes") or [] if x.get("type") == "SOLID" and x.get("visible") is not False]
                if st: parts.append("stroke=%s/%s" % (st[0], n.get("strokeWeight")))
                if n.get("cornerRadius"): parts.append("r=%g" % n["cornerRadius"])
                if n.get("rectangleCornerRadii"): parts.append("r=" + "/".join("%g" % x for x in n["rectangleCornerRadii"]))
                if n.get("layoutMode"):
                    parts.append("%s gap=%s pad=%s,%s,%s,%s" % (n["layoutMode"][0], n.get("itemSpacing", 0), n.get("paddingTop", 0), n.get("paddingRight", 0), n.get("paddingBottom", 0), n.get("paddingLeft", 0)))
                if n.get("opacity", 1) < 1: parts.append("op=%.2f" % n["opacity"])
                for e in n.get("effects") or []:
                    if e.get("visible") is not False and e["type"] == "DROP_SHADOW":
                        parts.append("shadow=%s %g,%g r%g" % (hexc(e["color"]), e["offset"]["x"], e["offset"]["y"], e["radius"]))
                if n.get("interactions"): parts.append("[tap]")
                if n["type"] == "TEXT":
                    t = n.get("style", {})
                    parts.append("%s %s %g lh=%s ls=%s %s" % (t.get("fontFamily"), t.get("fontWeight"), t.get("fontSize", 0),
                                 round(t.get("lineHeightPx", 0), 1), round(t.get("letterSpacing", 0), 2), t.get("textAlignHorizontal", "")[:1]))
                    parts.append(json.dumps(n.get("characters", ""), ensure_ascii=False))
                    lines.append("  " * d + " ".join(parts)); return
                lines.append("  " * d + " ".join(parts))
                if n["type"] in ("VECTOR", "BOOLEAN_OPERATION", "STAR", "LINE", "ELLIPSE", "REGULAR_POLYGON"): return
                # icon instances: don't descend into lucide internals
                if n["type"] == "INSTANCE" and all(c["type"] in ("VECTOR", "BOOLEAN_OPERATION", "GROUP") for c in n.get("children", [])) and b.get("width", 99) <= 32:
                    return
                for c in n.get("children", []): walk(c, d + 1)
            for c in f.get("children", []): walk(c, 0)
            code = f["name"].split(" ")[0]
            open(f"design/prototype/spec/{code}.txt", "w").write("\n".join(lines) + "\n")

if __name__ == "__main__":
    main(sys.argv[1])
