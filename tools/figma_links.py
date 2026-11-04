#!/usr/bin/env python3
"""Flatten the Figma Prototype page's prototype links into docs/figma-links.json.

Input: a REST dump of page 377:1195 (GET /v1/files/<key>/nodes?ids=377:1195).
Usage: python3 tools/figma_links.py <proto.json> docs/figma-links.json
REST drops string values on SET_VARIABLE; they are documented in Core/AppState.swift.
"""
import json, sys

VARS = {
    "728:170": "status", "728:171": "chip bg", "728:172": "chip text",
    "728:173": "borrower detail", "728:174": "lender detail", "920:192": "code timer",
    "735:172": "T has back", "735:173": "T has extra", "735:174": "J has back",
    "735:175": "J has extra", "735:176": "R has back", "735:177": "R has extra",
    "740:186": "up0 fill", "740:187": "up0 text", "740:188": "up1 fill", "740:189": "up1 text",
    "740:190": "rt0 fill", "740:191": "rt0 text", "740:192": "rt1 fill", "740:193": "rt1 text",
    "740:194": "rt2 fill", "740:195": "rt2 text", "740:196": "button fill", "740:197": "button text",
    "740:198": "button label", "740:199": "pick-up chosen", "740:200": "return chosen",
    "740:201": "pick-up selected", "740:202": "return selected", "740:203": "both selected",
}

def main(src, dst):
    page = json.load(open(src))["nodes"]["377:1195"]["document"]
    frames, order = {}, []
    for s in page["children"]:
        if s["type"] != "SECTION":
            continue
        for f in s.get("children", []):
            if f["type"] == "FRAME":
                frames[f["id"]] = {"id": f["id"], "name": f["name"], "code": f["name"].split(" ")[0],
                                   "section": s["name"], "tickTwin": s["name"].startswith("Countdown")}
                order.append(f)

    def label(fid):
        f = frames.get(fid)
        return f["code"] if f else fid

    def var_value(v):
        if not v: return None
        val = v.get("value")
        if isinstance(val, dict) and "r" in val:
            return "#%02X%02X%02X" % tuple(round(val[k] * 255) for k in "rgb")
        if isinstance(val, dict) and val.get("type") == "VARIABLE_ALIAS":
            return "alias:" + VARS.get(val["id"].replace("VariableID:", ""), val["id"])
        return val

    def cond(c):
        if not c: return None
        e = (c.get("value") or {})
        args = []
        for a in e.get("expressionArguments", []):
            v = a.get("value")
            if isinstance(v, dict) and v.get("type") == "VARIABLE_ALIAS":
                args.append("$" + VARS.get(v["id"].replace("VariableID:", ""), v["id"]))
            else:
                args.append(v)
        return {"fn": e.get("expressionFunction"), "args": args}

    def action(a):
        t = a["type"]
        if t == "NODE":
            d = a.get("destinationId")
            out = {"type": "navigate", "to": label(d), "toId": d}
            nav = a.get("navigation")
            if nav and nav != "NAVIGATE": out["navigation"] = nav
            if d in frames and frames[d]["tickTwin"]: out["tickTwin"] = True
            return out
        if t == "BACK":
            return {"type": "back"}
        if t == "SET_VARIABLE":
            vid = a["variableId"].replace("VariableID:", "")
            return {"type": "set", "var": VARS.get(vid, vid), "value": var_value(a.get("variableValue"))}
        if t == "CONDITIONAL":
            return {"type": "if", "blocks": [{"when": cond(b.get("condition")),
                                              "do": [action(x) for x in b.get("actions") or [] if x]}
                                             for b in a.get("conditionalBlocks", [])]}
        return {"type": t}

    links = []
    def walk(f, n):
        for it in n.get("interactions") or []:
            trig = it.get("trigger") or {}
            for a in it.get("actions") or []:
                if not a: continue
                rec = {"from": frames[f["id"]]["code"], "fromId": f["id"], "node": n["name"], "nodeId": n["id"],
                       "trigger": trig.get("type")}
                if trig.get("timeout") is not None: rec["timeout"] = trig["timeout"]
                rec["action"] = action(a)
                links.append(rec)
        for c in n.get("children", []):
            walk(f, c)
    for f in order:
        if not frames[f["id"]]["tickTwin"]:
            walk(f, f)

    screens = [v for v in frames.values() if not v["tickTwin"]]
    json.dump({"fileKey": "FRdguO9GdzR7f8EeSnaRNR", "page": "Prototype", "screens": screens, "links": links},
              open(dst, "w"), indent=1, ensure_ascii=False)
    nav = [l for l in links if l["action"]["type"] in ("navigate", "back")]
    print(f"{len(screens)} screens, {len(links)} actions, {len(nav)} direct navigations")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
