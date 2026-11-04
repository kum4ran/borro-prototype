#!/usr/bin/env python3
"""Print the "how to reach each screen" table for Docs/PROGRESS.md.

Shortest tap path from 1.1 over the Figma links plus the few links the app adds
(listed in EXTRA). Frames Figma never links to are reached from the demo menu.
"""
import json, re
from collections import deque

d = json.load(open("Docs/figma-links.json"))
names = {s["code"]: s["name"] for s in d["screens"]}
names["5.2f"] = "5.2f James · Apple Pay (sheet) [app only]"

def dests(a):
    if a["type"] == "navigate" and not a.get("tickTwin") and ":" not in a["to"]:
        yield a["to"]
    elif a["type"] == "if":
        for b in a["blocks"]:
            for x in b["do"]:
                yield from dests(x)

TAB = {"Navigation item", "Navigation destination", "Home", "Borro", "Lend", "You"}
TABNAME = {"1.1": "Home tab", "2.4": "Borro tab", "9.1": "Lend tab", "8.9": "You tab"}
edges = {}
for l in d["links"]:
    for t in dests(l["action"]):
        if t == l["from"] or t not in names:
            continue
        label = TABNAME.get(t) if l["node"] in TAB else l["node"]
        edges.setdefault(l["from"], []).append((t, label))

# Links the app adds on top of Figma (see Docs/PROGRESS.md, "Added links").
EXTRA = [("6.11", "6.12", "type a wrong code"), ("6.12", "6.14", "type 6767"), ("6.11", "6.14", "type 6767"),
         ("8.4", "8.5", "Thomas push banner"), ("8.8", "8.5", "Thomas push banner"),
         ("1.2", "1.1", "Need it Now toggle (off)"), ("5.2", "5.2f", "Apple Pay button")]
for a, b, label in EXTRA:
    edges.setdefault(a, []).insert(0, (b, label))

def natural(c):
    m = re.match(r"(\d+)\.(\d+)([a-z]?)", c)
    return (int(m.group(1)), int(m.group(2)), m.group(3))

prev = {"1.1": None}
q = deque(["1.1"])
while q:
    c = q.popleft()
    for t, label in edges.get(c, []):
        if t not in prev:
            prev[t] = (c, label)
            q.append(t)

print("| Frame | Name | How to reach it |")
print("|---|---|---|")
for code in sorted(names, key=natural):
    if code in prev:
        steps, c = [], code
        while prev[c]:
            p, label = prev[c]
            steps.append(f"{p} → *{label}*")
            c = p
        path = " · ".join(reversed(steps)) or "launch screen"
        if len(steps) > 6:
            path = "… " + " · ".join(list(reversed(steps))[-4:])
    else:
        path = "Demo menu (long-press the status bar) → All frames"
    print(f"| {code} | {names[code].split(' ', 1)[1]} | {path} |")
unreached = [c for c in names if c not in prev]
print(f"\n{len(names) - len(unreached)} of {len(names)} frames are reachable by tapping from 1.1; "
      f"{len(unreached)} only from the demo menu: {', '.join(sorted(unreached, key=natural))}.")
