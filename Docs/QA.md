# Implemented: all 13 Figma sections · 122 artboards

Design file: `FRdguO9GdzR7f8EeSnaRNR` (Borro) · pages `Screens`, `Prototype`.

Every artboard is implemented as a reachable screen or an explicit state
(sheet / dialog / branch) inside its flow, and every artboard can be opened
directly with the app's deep link (`-uiScreen <slug>`), which powers the review
index in **You → Figma design index**.

## Coverage

| # | Section | Artboards | Flow file | Screenshot folder |
|---|---|---|---|---|
| 1 | Discover | 5 | `HomeView.swift` | `docs/screens/qa/` |
| 2 | Request | 4 | `RequestFlow.swift` | same |
| 3 | Lender decides | 9 | `LenderDecisionFlow.swift` | same |
| 4 | Schedule & chat | 14 | `ScheduleChatFlow.swift` | same |
| 5 | Lending agreement | 6 | `AgreementFlow.swift` | same |
| 6 | Handover | 20 | `HandoverFlow.swift` | same |
| 6b | Photo steps | 12 | `HandoverFlow.swift` | same |
| 6c | Timeline stages | 2 | `HandoverFlow.swift` | same |
| 7 | Return | 6 | `ReturnFlow.swift` | same |
| 8 | Reviews & refund | 9 | `ReviewsFlow.swift` | same |
| 9 | My Lending & List an Item | 17 | `LendingFlow.swift` | same |
| 10 | Damage & cancellation | 13 | `DamageFlow.swift` | same |
| 11 | Borrow Later · Wishlist · AI chat | 5 | `OtherScreensFlow.swift` | same |

## Visual evidence

- `docs/screens/qa/<slug>.png` — 122 device screenshots, one per artboard.
- `docs/screens/compare/<slug>.jpg` — Figma render (left) vs SwiftUI (right) for
  all 122 artboards.
- `docs/screens/overview.jpg` — 12-screen montage of the main journey.

## Known deviations (deliberate)

1. **Full month calendars / time wheels / the two-circle map** in section 4 are
   local components matching the crops; the shared design-system pieces were a
   different geometry.
2. **Code boxes and photo cards** in sections 5/6 follow the crop geometry
   (58×60 boxes, 40pt digits, dashed 353×210 photo cards).
3. **Push notifications** (3.1, 3.8, 8.1, 8.5, 10.10) are in-app lock-screen
   mocks; the app cannot receive APNs pushes.
4. **Roboto Mono → Inter** for calendar numerals and timeline milestones, since
   only Inter ships with the prototype.
5. **Handshake tab icon** falls back to an exchange icon; SF Symbols has no
   handshake glyph on this runtime.
6. **In-flow bottom nav**: Figma artboards include the nav bar, so each flow
   renders its own 78pt bar; `AppShell` hides the root bar on pushed routes to
   avoid a double bar.
7. Figma frames are 393×852; on 402×874 devices (iPhone 16 Pro/17) the layout
   stretches by 9pt of width and the safe areas differ, so vertical rhythm is a
   few points off the fixed artboard heights.

## Regenerating evidence

```bash
tools/qa_all.sh          # rebuild + 122 screenshots
python3 tools/compare.py # 122 side-by-side images
```
