#!/usr/bin/env python3
"""Build per-artboard assets from the pulled Figma sections.

For each of the 122 artboards:
  design/figma/frames/<frame-id>.png   cropped @2x render
  design/figma/frames/<frame-id>.md    node subtree spec for that frame only
  design/figma/frames/<frame-id>.json  metadata (name, section, size, text, image refs)

Also writes design/figma/frames/index.json and a semantic photo index.
"""
import json
import os
import re
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIGMA = os.path.join(ROOT, "design", "figma")
FRAMES_DIR = os.path.join(FIGMA, "frames")
os.makedirs(FRAMES_DIR, exist_ok=True)

nodes = json.load(open(os.path.join(FIGMA, "nodes.json")))


def collect_text(node, out=None):
    if out is None:
        out = []
    if node.get("type") == "TEXT" and node.get("characters"):
        out.append(node["characters"].strip())
    for c in node.get("children") or []:
        collect_text(c, out)
    return out


def collect_images(node, out=None):
    if out is None:
        out = []
    for f in node.get("fills") or []:
        if f.get("type") == "IMAGE":
            ref = f.get("imageRef") or f.get("imageHash")
            if ref:
                out.append(ref)
    for c in node.get("children") or []:
        collect_images(c, out)
    return out


def crop_section(section_node, section_png, frame):
    bb = frame.get("absoluteBoundingBox") or {}
    sx = section_node.get("absoluteBoundingBox") or {}
    if not bb or not sx:
        return None
    im = Image.open(section_png)
    scale = im.width / sx["width"]
    left = (bb["x"] - sx["x"]) * scale
    top = (bb["y"] - sx["y"]) * scale
    right = left + bb["width"] * scale
    bottom = top + bb["height"] * scale
    box = tuple(int(round(v)) for v in (left, top, right, bottom))
    box = (max(0, box[0]), max(0, box[1]),
           min(im.width, box[2]), min(im.height, box[3]))
    return im.crop(box)


def slice_md(md_text, frame_name):
    """Return the markdown subtree for one artboard from the section spec."""
    lines = md_text.split("\n")
    start = None
    indent = None
    for i, line in enumerate(lines):
        m = re.match(r"^(\s*)- FRAME \| \"(.*?)\"", line)
        if m and m.group(2) == frame_name:
            start = i
            indent = len(m.group(1))
            break
    if start is None:
        return None
    end = len(lines)
    for j in range(start + 1, len(lines)):
        line = lines[j]
        if not line.strip():
            continue
        cur_indent = len(line) - len(line.lstrip(" "))
        if cur_indent <= indent and line.lstrip().startswith("- "):
            end = j
            break
    return "\n".join(lines[start:end])


index = {"sections": [], "frames": []}
photo_usage = {}

for section_key, section in nodes["nodes"].items():
    doc = section["document"]
    section_slug = section_key.replace(":", "-")
    section_png = os.path.join(FIGMA, "png", f"{section_slug}.png")
    if not os.path.exists(section_png):
        print("missing section render", section_png)
        continue
    md_path = os.path.join(FIGMA, "spec", f"{section_slug}.md")
    md_text = open(md_path).read() if os.path.exists(md_path) else ""

    sec_entry = {
        "node": section_key,
        "name": doc.get("name"),
        "frames": [],
    }
    for frame in doc.get("children") or []:
        if frame.get("type") != "FRAME":
            continue
        fid = frame["id"].replace(":", "-")
        bb = frame.get("absoluteBoundingBox") or {}
        if bb.get("width", 0) < 300:  # skip tiny components accidentally at root
            continue
        crop = crop_section(doc, section_png, frame)
        if crop is not None:
            crop.save(os.path.join(FRAMES_DIR, f"{fid}.png"))
        md = slice_md(md_text, frame.get("name", "")) if md_text else None
        if md:
            open(os.path.join(FRAMES_DIR, f"{fid}.md"), "w").write(
                f"# {frame.get('name')}\n\nSection: {doc.get('name')}\nFigma frame node: {frame['id']}\nFrame size: {round(bb.get('width',0))} x {round(bb.get('height',0))}\n\n"
                + md + "\n"
            )
        text = collect_text(frame)
        refs = sorted(set(collect_images(frame)))
        for ref in refs:
            photo_usage.setdefault(ref, []).append({
                "frame": frame["id"],
                "frameName": frame.get("name"),
                "section": doc.get("name"),
            })
        meta = {
            "id": frame["id"],
            "slug": fid,
            "name": frame.get("name"),
            "section": doc.get("name"),
            "sectionNode": section_key,
            "width": round(bb.get("width", 0)),
            "height": round(bb.get("height", 0)),
            "text": text,
            "imageRefs": refs,
            "png": f"frames/{fid}.png",
            "spec": f"frames/{fid}.md" if md else None,
        }
        json.dump(meta, open(os.path.join(FRAMES_DIR, f"{fid}.json"), "w"), indent=2)
        index["frames"].append(meta)
        sec_entry["frames"].append(fid)
    index["sections"].append(sec_entry)

json.dump(index, open(os.path.join(FRAMES_DIR, "index.json"), "w"), indent=2)

# Semantic photo names: infer from the frame names where each ref appears.
img_index = {}
for ref, uses in photo_usage.items():
    img_index[ref] = {
        "ref": ref,
        "file": f"images/{ref}.png",
        "usedIn": uses,
    }
json.dump(img_index, open(os.path.join(FIGMA, "images", "index.json"), "w"), indent=2)

print(f"frames: {len(index['frames'])}")
print(f"photos referenced: {len(img_index)}")
for s in index["sections"]:
    print(f"  {s['name'][:56]:58} {len(s['frames'])}")
