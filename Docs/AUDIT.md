# Borro prototype: audit (Phase 1)

3 Nov 2026 · audited the folder as received (baseline commit `bf57054`).

## Three worst problems

1. **No shared state.** Each of the 10 flow files is its own private state machine keyed on artboard slugs (`@State screen`, `startScreen:`). Borrowing status, deposit, photo sets, chosen times and the code countdown do not exist as shared state, so chips, codes and photo gating cannot follow the Figma variables (`Borro status`, `Borro photos`, `Borro times`, `code timer`).
2. **Wrong scenario data at the root.** `BorroStore` seeds every screen with "James Tan", rating 4.9 / 24 reviews / credibility 92, "Thomas Lim", codes 4821 / 7390, request REQ-1042, pick-up Sat 17 Oct and an "Anker Nebula" projector. Damage flow shows $50. None of it matches the brief.
3. **Navigation is not the Figma graph.** Links are hand-coded per flow, there is no typed route enum, no one-place sheet model, and the Figma prototype links were never dumped. The 5 PayNow / Terms frames added on 3 Nov (5.2a–5.2e) are missing.

## Build and run

- Builds for iOS Simulator (Xcode 26.2) in 17 s once the folder is out of iCloud: 0 errors, 5 warnings (4× unused `withAnimation` result, 1 AppIntents metadata). Launches to Home, no crash seen on launch.
- The original folder sits in iCloud Drive. Files were evicted ("dataless"); a build there took 23 min and failed. The project now lives at `~/Developer/Borro` (user approved). The asset-catalog step fails inside the agent sandbox; build with the catalog excluded or outside the sandbox.

## Structural problems

- Duplicated components: per-flow tab bars, photo tiles, star pickers, code boxes, push mocks (`RQ*`, `L*`, `O*` prefixes).
- 156 raw `Color(hex:)` and 182 `.font(.system…)` calls inside views; magic numbers throughout.
- `AnyView` in `Tokens.swift` and `OtherScreensFlow.swift`; 0 `#Preview`s; no unit or UI tests; no test targets.
- `TARGETED_DEVICE_FAMILY = 1,2` (iPad enabled); brief says iPhone only.
- Built against an older layout of the file (122 frames). The Prototype page now has 127 (13 sections incl. 6b, 6c).
- Dead code: `Features/FlowMap/*` (QA index), `-uiScreen` deep-link plumbing, `tools/qa_all.sh` harness tied to the old slugs.

## Decision: rebuild the shell, port the good parts

The navigation and state layer is the core of the brief and it does not exist in a reusable form; bolting one `AppState` and one `Router` onto ten private state machines would touch every line anyway. Rebuild App/Core/Components/Screens, and port what is correct: the 43 Figma photos, the Inter fonts (OFL licence), the token values and the layout knowledge in the old views.

## Screen table

Status legend: **L** links not driven by `figma-links.json`; **S** reads no shared state (status, photos, times, deposit or timer); **D** shows wrong scenario data from `BorroStore`. Classified from code review, not pixel comparison. No old screen is counted as correct: every one fails L.

| Code | Frame | Node | Status | Why |
|---|---|---|---|---|
| 3.1 | Thomas · Push · new request | 691:5139 | built, wrong | L S D |
| 3.2 | Thomas · Borrow Requests | 700:125 | built, wrong | L S D |
| 3.3 | Thomas · Borrow request expanded | 700:198 | built, wrong | L S D |
| 3.4 | Thomas · James public profile | 691:5216 | built, wrong | L S D |
| 3.6 | Thomas · James all reviews | 691:5308 | built, wrong | L S D |
| 3.7 | Thomas · Accept James' request? (dialog) | 700:439 | built, wrong | L S D |
| 3.8 | James · Push · request accepted | 700:520 | built, wrong | L S D |
| 3.9 | James · Request accepted | 691:5405 | built, wrong | L S D |
| 3.5 | Thomas · Credibility score info | 701:124 | built, wrong | L S D |
| 4.1 | James · Propose handover | 701:203 | built, wrong | L S D |
| 4.2 | James · Pick-up dates (pop-up) | 701:284 | built, wrong | L S D |
| 4.3 | James · Pick-up times (pop-up) | 701:429 | built, wrong | L S D |
| 4.4 | James · Return dates (pop-up) | 701:585 | built, wrong | L S D |
| 4.5 | James · Return times (pop-up) | 701:762 | built, wrong | L S D |
| 4.6 | James · Pick on map | 701:951 | built, wrong | L S D |
| 4.7 | James · Times chosen | 701:1059 | built, wrong | L S D |
| 4.8 | James · Proposal sent | 701:1177 | built, wrong | L S D |
| 4.9 | James · Chat with Thomas | 691:5576 | built, wrong | L S D |
| 4.10 | James · Chat attachment menu | 701:1267 | built, wrong | L S D |
| 4.11 | Thomas · Review proposal | 701:1366 | built, wrong | L S D |
| 4.12 | Thomas · Choose times (pop-up) | 701:1464 | built, wrong | L S D |
| 4.13 | Thomas · Request changes (branch) | 701:1626 | built, wrong | L S D |
| 4.14 | Both · Handover confirmed | 701:1718 | built, wrong | L S D |
| 5.1 | Thomas · Agreement sent | 691:5698 | built, wrong | L S |
| 5.2 | James · Final Agreement | 691:5763 | built, wrong | L S |
| 5.3 | James · Lender care note | 691:5836 | built, wrong | L S |
| 5.4 | James · Deposit info | 691:5930 | built, wrong | L S |
| 5.5 | James · Deposit paid | 691:6006 | built, wrong | L S |
| 5.6 | James · Agreement submitted | 691:6074 | built, wrong | L S |
| 5.2a | James · PayNow · Confirm payment (sheet) | 902:185 | missing | Frame added to Figma 3 Nov; no view |
| 5.2b | James · PayNow · Scan to pay | 902:266 | missing | Frame added to Figma 3 Nov; no view |
| 5.2c | James · PayNow · Processing payment | 902:330 | missing | Frame added to Figma 3 Nov; no view |
| 5.2d | James · Payment successful | 902:385 | missing | Frame added to Figma 3 Nov; no view |
| 5.2e | Both · Terms & Conditions | 925:193 | missing | Frame added to Figma 3 Nov; no view |
| 1.1 | James · Home | 691:4139 | built, wrong | L |
| 1.2 | James · Home · Need it Now on | 691:4256 | built, wrong | L |
| 1.3 | James · Filter menu | 691:4365 | built, wrong | L |
| 1.4 | James · Location map · 1 km | 691:4492 | built, wrong | L |
| 1.5 | James · Results · steamer within 1 km | 691:4657 | built, wrong | L D |
| 2.1 | James · Item details · Garment Steamer | 691:4767 | built, wrong | L S D |
| 2.2 | James · Borrow request · Borrow Now | 691:4822 | built, wrong | L S D |
| 2.3 | James · Request sent · waiting for Thomas | 691:5008 | built, wrong | L S D |
| 2.4 | James · My Borrowing | 691:5063 | built, wrong | L S D |
| 6.1 | Thomas · Drop-off · lender code | 691:6129 | built, wrong | L S D |
| 6.2 | Thomas · Lender code info (sheet) | 703:434 | built, wrong | L S D |
| 6.6 | Thomas · Add additional photos | 703:765 | built, wrong | L S D |
| 6.7 | Thomas · Photo options (delete / upload / retake) | 703:1074 | built, wrong | L S D |
| 6.8 | Thomas · Edit photo name (sheet) | 703:1403 | built, wrong | L S D |
| 6.9 | Thomas · Ready to submit? (sheet) | 703:1718 | built, wrong | L S D |
| 6.10 | Thomas · Drop-off saved · share code | 703:2035 | built, wrong | L S D |
| 6.11 | James · Collection · enter lender code | 691:6435 | built, wrong | L S D |
| 6.12 | James · Wrong code | 703:2090 | built, wrong | L S D |
| 6.13 | James · Meet in person first (sheet) | 703:2171 | built, wrong | L S D |
| 6.14 | James · Code verified | 703:2262 | built, wrong | L S D |
| 6.17 | James · Missing photos (sheet) | 703:2342 | built, wrong | L S D |
| 6.15 | James · Photo added | 703:2430 | built, wrong | L S D |
| 6.16 | James · Photo options | 703:2512 | built, wrong | L S D |
| 6.18 | James · Ready to submit? (sheet) | 703:2615 | built, wrong | L S D |
| 6.19 | Both · Handover summary | 691:6511 | built, wrong | L S D |
| 6.20 | Both · Timeline · ongoing | 691:6585 | built, wrong | L S D |
| 6.3 | Thomas · Name the photo (sheet) | 704:166 | built, wrong | L S D |
| 6.4 | Thomas · Front photo added | 704:484 | built, wrong | L S D |
| 6.5 | Thomas · Back photo (empty) | 704:792 | built, wrong | L S D |
| 7.1 | James · Return code + after photos | 691:6651 | built, wrong | L S D |
| 7.2 | Thomas · Enter borrower code | 703:2705 | built, wrong | L S D |
| 7.3 | Thomas · Return photo added | 703:2785 | built, wrong | L S D |
| 7.4 | Thomas · Ready to submit? (sheet) | 703:2867 | built, wrong | L S D |
| 7.5 | Both · Return confirmed | 691:6709 | built, wrong | L S D |
| 7.6 | Both · Timeline · refund processing | 703:2954 | built, wrong | L S D |
| 8.1 | James · Push · rate Thomas | 703:3018 | built, wrong | L S D |
| 8.2 | James · Rate Thomas | 691:6828 | built, wrong | L S D |
| 8.3 | James · Rate Thomas · filled | 703:3041 | built, wrong | L S D |
| 8.4 | James · Review submitted | 691:6916 | built, wrong | L S D |
| 8.5 | Thomas · Push · rate James | 703:3129 | built, wrong | L S D |
| 8.6 | Thomas · Rate James | 691:6963 | built, wrong | L S D |
| 8.7 | Thomas · Review submitted | 703:3152 | built, wrong | L S D |
| 8.8 | Both · Timeline · deposit refunded | 691:6764 | built, wrong | L S D |
| 8.9 | James · Profile | 691:7051 | built, wrong | L S D |
| 9.1 | Thomas · My Lending · Active | 708:170 | built, wrong | L S |
| 9.2 | Thomas · My Lending · Sort / Filter | 708:275 | built, wrong | L S |
| 9.3 | Thomas · My Lending · Past loans | 708:414 | built, wrong | L S |
| 9.4 | Thomas · Past loans · Sort / Filter | 708:518 | built, wrong | L S |
| 9.5 | Thomas · Manage listing menu | 708:648 | built, wrong | L S |
| 9.6 | Thomas · Paused listing | 708:775 | built, wrong | L S |
| 9.7 | Thomas · Delete confirmation | 708:889 | built, wrong | L S |
| 9.8 | Thomas · List an Item · Step 1 photos | 708:1002 | built, wrong | L S |
| 9.9 | Thomas · Step 2 details | 708:1065 | built, wrong | L S |
| 9.10 | Thomas · Step 3 pick-up | 708:1135 | built, wrong | L S |
| 9.11 | Thomas · Step 4 availability | 708:1214 | built, wrong | L S |
| 9.12 | Thomas · Step 5 period | 708:1363 | built, wrong | L S |
| 9.13 | Thomas · Step 6 deposit | 708:1421 | built, wrong | L S |
| 9.14 | Thomas · Step 7 care | 708:1510 | built, wrong | L S |
| 9.15 | Thomas · Step 8 terms | 708:1574 | built, wrong | L S |
| 9.16 | Thomas · Listing preview | 708:1634 | built, wrong | L S |
| 9.17 | Thomas · Steamer is live | 708:1691 | built, wrong | L S |
| 10.1 | James · Report damage · incomplete | 708:1742 | built, wrong | L |
| 10.2 | James · Report damage · filled | 708:1842 | built, wrong | L |
| 10.3 | James · Damage tracker · submitted | 708:1942 | built, wrong | L |
| 10.4 | James · Damage tracker · evaluating | 708:2017 | built, wrong | L |
| 10.5 | James · Damage tracker · verifying | 708:2089 | built, wrong | L |
| 10.6 | Both · Timeline · damage | 708:2160 | built, wrong | L |
| 10.7 | Both · Timeline · repair | 708:2234 | built, wrong | L |
| 10.8 | Both · Post-Borro review · damage | 708:2298 | built, wrong | L |
| 10.9 | Both · Repair balance paid | 708:2371 | built, wrong | L |
| 10.10 | James · Push · borrowing cancelled | 708:2421 | built, wrong | L |
| 10.11 | James · Borrowing cancelled · alternatives | 708:2443 | built, wrong | L |
| 10.12 | James · Nearby alternatives | 708:2513 | built, wrong | L |
| 10.13 | James · Find new lender | 708:2598 | built, wrong | L |
| 11.1 | James · Item details · Borrow Later | 708:2691 | built, wrong | L |
| 11.2 | James · Borrow Later · pick dates | 708:2877 | built, wrong | L |
| 11.3 | James · Borrow Later · request sent | 708:2984 | built, wrong | L |
| 11.4 | James · Wishlist | 708:3039 | built, wrong | L |
| 11.5 | James · Ask Borro (AI chat) | 708:3121 | built, wrong | L |
| 6.3a | Thomas · Name the back photo (sheet) | 736:170 | built, wrong | L S D |
| 6.3b | Thomas · Name the extra photo (sheet) | 736:486 | built, wrong | L S D |
| 6.5a | Thomas · Back photo added | 736:804 | built, wrong | L S D |
| 6.6a | Thomas · Extra photo added | 736:1115 | built, wrong | L S D |
| 6.14a | James · Front photo added | 736:1432 | built, wrong | L S D |
| 6.14b | James · Back photo (empty) | 736:1533 | built, wrong | L S D |
| 6.14c | James · Back photo added | 736:1634 | built, wrong | L S D |
| 6.14d | James · Add additional photos | 736:1738 | built, wrong | L S D |
| 7.2a | Thomas · Front photo added | 736:1844 | built, wrong | L S D |
| 7.2b | Thomas · Back photo (empty) | 736:1945 | built, wrong | L S D |
| 7.2c | Thomas · Back photo added | 736:2046 | built, wrong | L S D |
| 7.2d | Thomas · Add additional photos | 736:2150 | built, wrong | L S D |
| 5.7 | Both · Timeline · agreed | 739:225 | built, wrong | L S |
| 6.10a | Both · Timeline · meet-up | 739:311 | built, wrong | L S D |
