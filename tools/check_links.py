#!/usr/bin/env python3
"""Check every Figma prototype link (Docs/figma-links.json) against the SwiftUI code.

For each link "frame A, node N → frame B" the script looks for `.sB` in the view file for A
and in every project type that view uses (followed three levels deep). Tab-bar links pass when
the frame shows AppTabBar; "Close sheet (tap handle)" links pass when the frame is a sheet
(SheetHandle dismisses to the page underneath); BACK passes for any frame with a back chevron.
Limits: it proves the destination is wired from that frame, not which button carries it.
The UI test (Tests/BorroUITests) walks the story path for real.

Usage: python3 tools/check_links.py  → prints a summary, writes Docs/link-check.md, exits 1 on gaps.
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
links = json.load(open(os.path.join(ROOT, "Docs/figma-links.json")))
screen_src = open(os.path.join(ROOT, "Borro/Core/Screen.swift")).read()

# frame code → case, view type, tab, presentation
cases = dict(re.findall(r'case \.(s[\w]+): return "([\d.a-z]+)"', screen_src.split("var frameName")[0]))
code_to_case = {v: k for k, v in cases.items()}
views = dict(re.findall(r"case \.(s\w+): (S\w+View)\(\)", screen_src))
tabs = dict(re.findall(r"case \.(s\w+): return (nil|\.\w+)\n", screen_src.split("var tab:")[1].split("var presentation")[0]))
pres = dict(re.findall(r"case \.(s\w+): return (\.\w+)", screen_src.split("var presentation")[1].split("var view")[0]))

router_src = open(os.path.join(ROOT, "Borro/Core/Router.swift")).read()
page_under = dict(re.findall(r"\.(s\w+): \.(s\w+)", router_src.split("static let pageUnder")[-1]))

# every Swift file and the types it defines
files, defines = {}, {}
# Only screens and components count: Core (Router, demo fixtures) and the demo menu name every frame.
for d, _, fs in [w for sub in ("Borro/Screens", "Borro/Components") for w in os.walk(os.path.join(ROOT, sub))]:
    for f in fs:
        if f.endswith(".swift") and f != "Screen.swift":
            p = os.path.join(d, f)
            files[p] = open(p).read()
            for t in re.findall(r"(?:struct|enum|class|extension)\s+(\w+)", files[p]):
                defines.setdefault(t, set()).add(p)

def reachable_text(view_type, depth=3):
    seen_files, frontier = set(), set(defines.get(view_type, set()))
    for _ in range(depth + 1):
        new = set()
        for p in frontier - seen_files:
            seen_files.add(p)
            for ident in set(re.findall(r"\b([A-Z]\w+)\b", files[p])):
                # follow shared types, not other frames' views (S1_1_…View)
                if ident in defines and not re.match(r"S\d+_", ident):
                    new |= defines[ident]
        frontier = new
    return "\n".join(files[p] for p in seen_files)

def destinations(action):
    if action["type"] == "navigate":
        yield action["to"]
    elif action["type"] == "back":
        yield "BACK"
    elif action["type"] == "if":
        for block in action["blocks"]:
            for a in block["do"]:
                yield from destinations(a)

TAB_ROOTS = {"1.1", "2.4", "9.1", "8.9"}
results, cache = [], {}
for link in links["links"]:
    src = link["from"]
    for dest in destinations(link["action"]):
        if link["action"].get("tickTwin") or dest.startswith("9") and ":" in dest:
            continue
        case = code_to_case.get(src)
        if ":" in dest:                      # component variant change (Terms card expand)
            ok, how = True, "component variant (TermsCard expand)"
        elif dest == "BACK":
            text = cache.setdefault(case, reachable_text(views[case]))
            ok, how = ("router.back()" in text or "BackAppBar" in text or "IconButton(icon: .chevronLeft" in text), "back"
        elif dest in TAB_ROOTS and link["node"] in ("Navigation item", "Navigation destination", "Home", "Borro", "Lend", "You"):
            ok, how = (tabs.get(case) != "nil" or pres.get(case) in (".sheet", ".overlay")), "tab bar"
        elif "Close sheet" in link["node"] or "Tap to close" in link["node"]:
            ok, how = pres.get(case) == ".sheet", "sheet handle"
        elif pres.get(case) in (".sheet", ".overlay") and link["node"] == next(
                s["name"] for s in links["screens"] if s["code"] == src) and page_under.get(case) == code_to_case.get(dest):
            ok, how = True, "scrim tap returns to the page underneath"
        else:
            text = cache.setdefault(case, reachable_text(views[case]))
            target = code_to_case.get(dest, "?")
            ok = re.search(r"\.%s\b" % re.escape(target), text) is not None
            how = "code"
            under = page_under.get(case)
            if not ok and under and pres.get(case) in (".sheet", ".overlay"):
                # Figma draws the page under a sheet into the sheet frame; its buttons live on that page.
                ok = re.search(r"\.%s\b" % re.escape(target), cache.setdefault(under, reachable_text(views[under]))) is not None
                how = "button on the page underneath the sheet"
        results.append((src, link["node"], dest, ok, how))

gaps = [r for r in results if not r[3]]
lines = ["# Link check", "", f"{len(results)} Figma link destinations checked, {len(results) - len(gaps)} wired, {len(gaps)} missing.", "",
         "Generated by `python3 tools/check_links.py` from Docs/figma-links.json.", ""]
if gaps:
    lines += ["## Missing", "", "| From | Node | To |", "|---|---|---|"] + [f"| {a} | {b} | {c} |" for a, b, c, _, _ in gaps]
open(os.path.join(ROOT, "Docs/link-check.md"), "w").write("\n".join(lines) + "\n")
print(lines[2])
for g in gaps:
    print("  MISSING", g[0], "·", g[1], "→", g[2])
sys.exit(1 if gaps else 0)
