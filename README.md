# Borro: SwiftUI prototype

A clickable iPhone prototype of Borro, a neighbour item-borrowing app. It walks the Figma
prototype (file `FRdguO9GdzR7f8EeSnaRNR`, page **Prototype**) click for click: James borrows
Thomas's garment steamer the night before an interview, from search to the deposit refund.

Demo build: no backend, no network, no persistence. Everything runs on mock data in memory.

- iOS 17+, iPhone, portrait, light mode. SwiftUI, Swift 5.9+, no third-party packages.
- 127 screens, one view per Figma frame (`Borro/Screens/S01_Discover` … `S11_Other`).

## Run it

1. Open `Borro.xcodeproj` in Xcode 15 or later (built with Xcode 26.2).
2. Pick an iPhone simulator (iOS 17+) and press **Run**.
3. On a real iPhone: target **Borro** → Signing & Capabilities → choose your team. The bundle id is `com.tjandera.borro`; change it if your team rejects it.

From the command line (simulator):

```bash
xcodebuild -project Borro.xcodeproj -scheme Borro -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Inside a sandbox that blocks Apple's asset-catalog tool, build without the catalog (no app icon or accent colour):

```bash
tools/build.sh --no-assets
```

## Demo controls

- **Demo menu**: long-press the status bar. Jump to the first screen of any section, or to any frame. The app state is set to match that point in the story. **Reset demo** restores the launch state.
- **Role switch**: the phone plays both James and Thomas. When the story moves to the other person a banner says "Now viewing as Thomas".
- **Every story choice is live**: radius (1.4), borrowing dates (2.2), pick-up and return days and times (4.2–4.5), the meeting spot (4.6), Thomas's pick (4.12), PayNow or Apple Pay (5.2) and star ratings (8.2). Later screens show what you chose; the list is in `Docs/PROGRESS.md`.
- **Open a frame directly**: `xcrun simctl launch booted com.tjandera.borro -startScreen 5.2`.

The story path: Home → Need it Now → Filter → 1 km → steamer → Borrow Now → My Borrowing → tap the card (Thomas's phone) → accept → arrange handover → PayNow → handover codes and photos (6767, then 8482 at return) → reviews → refund.

## Tests

```bash
xcodebuild test -project Borro.xcodeproj -scheme Borro -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

- `Tests/BorroTests`: state rules (status transitions, deposit, countdown wrap, code checks, photo gating, times, role switching, router).
- `Tests/BorroUITests`: the whole story path from 1.1 to 8.9, plus the code countdown.

Check every Figma link against the code:

```bash
python3 tools/check_links.py
```

## Layout

```
Borro/App/         entry point, root view (stack, sheet, overlay, banner), demo menu, preview host
Borro/Core/        Theme, AppState, Router, Screen (generated), Models, MockData, Constants, demo fixtures
Borro/Components/  buttons, tab bar, sheets, chips, cards, code boxes, photo slots, timeline, icons
Borro/Screens/     one folder per Figma section, one file per frame
Borro/Resources/   Inter fonts, photos exported from Figma
Docs/              AUDIT.md, PROGRESS.md (conflicts, decisions, how to reach each screen),
                   figma-links.json, link-check.md, screens/compare (Figma vs app)
design/prototype/  Figma renders (png), per-frame specs, icon SVGs
tools/             link dump, specs, screen enum and icon generators, link check, screenshots
```

## Updating from Figma

```bash
# needs a read-only Figma token in .figma_token (git-ignored)
curl -s -H "X-Figma-Token: $(cat .figma_token)" \
  "https://api.figma.com/v1/files/FRdguO9GdzR7f8EeSnaRNR/nodes?ids=377:1195" > /tmp/proto.json
python3 tools/figma_links.py /tmp/proto.json Docs/figma-links.json
python3 tools/gen_screens.py            # regenerates Borro/Core/Screen.swift
python3 tools/check_links.py
tools/shots.sh all                      # screenshots + side-by-sides in Docs/screens/compare
```

Open questions for the team (return time, required photos and others) are in `Docs/PROGRESS.md`.
