# Borro prototype: progress

4 Nov 2026 · project at `~/Developer/Borro` (moved out of iCloud Drive, see AUDIT.md).

## Status against the definition of done

| Item | State |
|---|---|
| Builds, 0 errors, 0 warnings | Yes. Full simulator build including `Assets.xcassets` (app icon, accent colour): 0 errors, 0 warnings (Xcode 26.2). Not built or signed for a physical iPhone here. |
| Story path 1.1 → 8.9, no dead end, no placeholder | Yes. `StoryPathUITests.testFullStoryPath` walks it (passes, ~3 min). |
| All 127 screens reachable | Yes. 111 by tapping from 1.1, 16 only from the demo menu because Figma has no link into them (table below). |
| Every Figma link goes where Figma says | 791 / 791 link destinations wired (`python3 tools/check_links.py`, report in `Docs/link-check.md`). Exceptions on purpose are listed under "Deviations". |
| Side-by-side comparison per screen | `Docs/screens/compare/<frame>.jpg`, Figma left, app right (iPhone 17 Pro). |
| Unit tests and UI test pass | 30 unit tests, 5 UI tests (story path, chosen dates, chosen times, Apple Pay, countdown), all passing (last run 5 Nov 2026, iPhone 17 Pro, iOS 26.2). |
| Conflicts listed | Below. |
| iPhone SE, Dynamic Type xxxLarge | Checked, see "Small phone and Dynamic Type". |

## Live choices (added 5 Nov 2026)

Every choice on the story path now changes state, and every later screen shows what was picked. Figma only covers the default path; these extra outcomes are app behaviour.

| Choice | Where you pick | Where it shows |
|---|---|---|
| Search radius (Current, 500 m, 1 km, 2 km, 5 km) | 1.4 slider (tap a stop or drag) | 1.4 "Searching within …", 1.3 Location value, 1.5 results and count |
| Borrowing dates (18–27 Oct, up to 7 days; 15–17 Oct busy, earlier days past) | 2.2 calendar: first tap starts, a later day ends | 2.2 summary, 2.3/3.9 request card, 3.1/3.8 pushes, 3.2/3.3 requests and calendar, 3.7 dialog, 2.4/9.1 detail lines, 5.x agreement, T&C, receipts, 8.x pushes |
| Pick-up day / return day (inside the borrowing range, return not before pick-up) | 4.2 / 4.4 calendars | 4.3/4.5 headers, 4.7, 4.8, 4.11, 4.12, 4.13, and every agreed date after 4.14 |
| Pick-up / return times James offers | 4.3 / 4.5 wheel: "Add", tap a chip to remove, "Clear times"; same-day returns must come after pick-up | 4.7 fields, 4.8/4.11 rows, 4.12 pills, 4.13 fields |
| The one time Thomas picks of each | 4.12 pills (from James's offers) | 4.14 and everything after: agreement, chat, timelines, handover, return, status lines on 2.4 and 9.1 |
| Meeting spot (Block A Security Desk, Blk 12, Blk 48; Thomas can suggest West Wing Lobby or "Arrange via chat") | 4.6 list under the map; 4.13 radio | 4.1, 4.7, 4.8, 4.11, 4.14, chat, agreement, T&C, timelines, handover and return headers, status lines |
| Deposit payment method (PayNow, Apple Pay) | 5.2 buttons | 5.2c, 5.2d receipt "Method", 5.5 deposit panel, 5.6, 5.1 |
| Star ratings | 8.2 first tap fills every category with the stars tapped; 8.3 / 8.6 per row | 8.4 / 8.7 "saved review" with the average |

New app-only frame: **5.2f Apple Pay (sheet)**, a simulated Apple Pay sheet (no Wallet, no charge) → 5.2c → 5.2d. Screen count is now 128 (127 Figma + 1).

Not made live (side branches or outside the agreed scope): 1.3 Rating / Reviews / Availability filter rows, the 1.4 custom-radius field, Reject on 3.2/3.3, and every section 9–11 control.

## Decisions

- **Rebuilt the shell, ported assets.** The old code had per-flow private state machines and wrong scenario data at the root. New `AppState` (one `@Observable`), one `Router` with a typed `Screen` enum generated from the Figma file (`tools/gen_screens.py`), one view per frame.
- **Navigation model.** A Figma link names a frame, not a direction. `Router.go(_:)` presents sheet frames as sheets, overlay frames (1.3, 3.7, 6.7, 6.16, 9.7) over the page, pops back when the target is already in the stack, pushes otherwise.
- **Role switching.** Every move to a James-only or Thomas-only frame sets `currentUser` and shows "Now viewing as …". The three simulated jumps the brief names (2.4 → 3.1, 4.8 → 4.11, 8.4 → 8.5) are covered, plus the others the story implies (3.7 → 3.8 and so on).
- **Demo menu.** Long-press the status bar. Jumps to any section or frame and puts `AppState` where the story would be at that frame (`DemoFixtures.swift`). "Reset demo" restores launch state.
- **Icons** are the Figma Lucide vectors, exported as SVG and compiled into `Components/IconData.swift` (drawn with `Canvas`). They are not in the asset catalog, because asset-catalog builds cannot run in the agent sandbox and code-drawn vectors scale and tint the same way. Only the Apple logo on the Apple Pay button is an SF Symbol.
- **Inter** is bundled (SIL Open Font Licence, `Resources/Fonts/Inter-LICENSE.txt`) and scales with Dynamic Type (`Font.custom(_:size:relativeTo:)`).
- **PayNow logo**: the Figma bitmap has a black background; a keyed-out copy (`paynow_logo.png`) is used on the white button.
- **Code entry** (6.11, 7.2) is a real number field behind the four boxes. 6.11: wrong code → 6.12, 6767 → 6.14. Tapping the boxes before Thomas has saved the drop-off opens 6.13.
- **Ask Borro (11.5)** answers from a scripted keyword table in `MockData`. No network, no model calls.

## Conflicts (scenario first, then Figma, then the old folder)

Please confirm. Each one is one value in `Core/Constants.swift` or `Core/MockData.swift` unless noted.

| # | Figma | What the app does | Where |
|---|---|---|---|
| 1 | Return time 10:00 am (5.2, status strings, Borro times default, T&C, 4.9 chat) | Monday 19 Oct, **11:00 pm** everywhere | `Scenario.returnTime` |
| 2 | Return pills 9 am / 10 am / 10:30 am (4.5, 4.7, 4.11, 4.12) | James's default offers are 10 pm / **11 pm** / 11:30 pm (11 pm is `Scenario.defaultReturnTime`); he can add or remove any time on 4.5, and later screens show the one Thomas picks | `MockData.defaultReturnOffers` |
| 3 | 5.1 shows "Deposit paid" before James pays | "Awaiting deposit" until the deposit is held | `S5_1_AgreementSentView` |
| 4 | Apple Pay on 5.2 has no link | Wired to an app-only simulated sheet (5.2f) so the option has its own path | `S5_2f_ApplePaySheetView` |
| 5 | 8482 on 6.3a, 6.3b, 6.5a, 6.6a (and 6.14a–d); 6767 on 7.1 | Handover shows 6767, return shows 8482 | `LenderCodeTop`, `S7_1_…` |
| 6 | "Portable Steamer" / "Steamer Screen" over projector photos (11.4) | "Portable Projector" / "Projector Screen" | `MockData.wishlist` |
| 7 | Calendar highlights don't match 18–19 Oct | The chosen days are highlighted (18 and 19 Oct by default); 2.1 says "18–27 Oct · Free" to match the days you can pick | `CalendarMonth` |
| 8 | Meet-up "reception" (scenario) vs Block A Security Desk; "West Wing Lobby" on 9.10 / 9.16 | Block A Security Desk everywhere | `Scenario.meetUpPlace` |
| 9 | Status bar 10:00 on every frame | Real status bar | — |
| 10 | 8.9 credibility after reviews | 72/100, as Figma shows | `MockData.james` |
| 11 | **Required photos**: brief says front only; Figma copy says "Front and back are required" and links 6.14a → Missing photos | Front only. One switch: `PhotoRules.backRequired`. With it off, 6.4 / 6.14a / 7.2a can submit and the copy says "The front photo is required" | `PhotoFlow.swift` |
| 12 | 5.7 and 6.10a buttons set status to "Return pending" (copy of 6.20) | Only 6.20 sets Return pending | `TimelineCopy` |
| 13 | 8.4's button goes to 8.8; the brief's jump is 8.4 → 8.5 | Button keeps 8.8. A "Meanwhile, on Thomas's phone" banner on 8.4 and 8.8 makes the jump to 8.5 | `S8_4_…`, `BorrowTimeline` |
| 14 | Avatars reused across lenders; 1.3 labels the JBL lender "Thomas" | One fixed avatar per person, JBL is Kumaran's | `MockData` |
| 15 | 9.3 past loans "Lent to Thomas" on Thomas's own list | "Lent to Kumaran" | `MockData.pastLending` |
| 16 | 9.13 amount field "$ 50" while $10 is selected | $10 | `S9_13_…` |
| 17 | 10.7 Thomas "★ 4.7 · 47 reviews" | ★ 5.0 · 10 reviews | `S10_7_…` |
| 18 | Damage photos (10.x) show a black speaker | Steamer photos | `MockData.damageAngles` |
| 19 | 7.2 shows the borrower code already verified | Thomas types 8482 (brief) | `BorrowerCodeEntryTop` |
| 20 | Figma page has 127 frames in 13 sections (brief says 126 / 11) | All 127 built | — |

## Deviations from Figma links (on purpose)

- Photo submit with front only (conflict 11): 6.4 → 6.9, 6.14a → 6.18 and 7.2a → 7.4 instead of no link / 6.17.
- Unwired Figma buttons stay inert: 2.3 "Chat with Thomas", 3.2 Accept/Reject on cards, Reject on 3.3, 5.1 "Edit Agreement", 5.3 Copy/Download, timeline "View Agreement" and "Before / After", 9.5 "Mark as Important", 9.10 "Pick on map", 10.x "Request" buttons, "Search for other".
- 4.13 "Arrange via chat" sends Thomas to the chat (4.9) instead of back to 4.11; the other spots keep Figma's 4.11 link.
- 4.7 "Send Proposal" is disabled while James has removed every pick-up or return time.

## Added links (not in Figma)

- 6.11 / 6.12 code entry → 6.12 (wrong) or 6.14 (6767). 7.2 code entry verifies in place.
- 8.4 and 8.8 → 8.5 ("Meanwhile, on Thomas's phone").
- 1.2 Need it Now toggle → back to 1.1. The steamer card on 1.1 / 1.2 / 11.4 → 2.1.
- 8.9 rows: My Listings → 9.1, My Borrowing → 2.4, Wishlist → 11.4, Reviews → 3.6.
- 3.4 → 3.5 also from the credibility label; tooltip on 3.5 closes to 3.4 (Figma wires both).

## Assumptions

- Thomas's other listings (Water Bottle, Speaker, Camera) and the alternatives in section 10 keep their Figma data: side branches, not the story path.
- The 4.12 sheet starts with nothing selected; "Confirm times" only enables once both pills are chosen (Figma variable logic).
- 8.2: the first star tap fills every category (Figma's single "Five star controls" link to 8.3). On 8.3 each row is tappable.

## Small phone and Dynamic Type

Checked on an iPhone SE (3rd generation) simulator, at the default text size and at **xxxLarge**
(screenshots in `Docs/screens/se/` and `Docs/screens/se-xxxl/`, git-ignored; regenerate with
`DEVICE="Borro-SE" OUT=Docs/screens/se tools/shots.sh 1.1 2.1 …`).

- Default size: every checked frame (1.1, 2.1, 2.2, 2.3, 3.3, 4.2, 4.7, 4.12, 5.2, 5.2b, 6.1, 6.9, 6.11, 6.19, 7.1, 8.3, 8.9, 9.13) fits, scrolls where Figma scrolls, and keeps the sticky actions above the tab bar.
- xxxLarge: fixed after the first pass. App bar titles and buttons stay on one line (scaled down to 70% at most), tab labels never wrap, the 4.12 time pills drop under the day label when the row no longer fits, star category labels stay on one line, the code ring text stays inside the ring, and sheets scroll when large text outgrows their Figma height.
- Accessibility sizes above xxxLarge are capped at xxxLarge (`RootView`), as the brief only asks for xxxLarge.

## How to reach every screen

Path labels are Figma layer names (often "Action" for a button). Shortest path from 1.1.

| Frame | Name | How to reach it |
|---|---|---|
| 1.1 | James · Home | launch screen |
| 1.2 | James · Home · Need it Now on | 1.1 → *Urgency toggle* |
| 1.3 | James · Filter menu | 1.1 → *Urgency toggle* · 1.2 → *sliders-horizontal* |
| 1.4 | James · Location map · 1 km | 1.1 → *Urgency toggle* · 1.2 → *sliders-horizontal* · 1.3 → *Filter option* |
| 1.5 | James · Results · steamer within 1 km | 1.1 → *Urgency toggle* · 1.2 → *sliders-horizontal* · 1.3 → *Filter option* · 1.4 → *Action* |
| 2.1 | James · Item details · Garment Steamer | 1.1 → *Urgency toggle* · 1.2 → *sliders-horizontal* · 1.3 → *Filter option* · 1.4 → *Action* · 1.5 → *Marketplace item* |
| 2.2 | James · Borrow request · Borrow Now | 1.1 → *Urgency toggle* · 1.2 → *sliders-horizontal* · 1.3 → *Filter option* · 1.4 → *Action* · 1.5 → *Marketplace item* · 2.1 → *Action* |
| 2.3 | James · Request sent · waiting for Thomas | … 1.4 → *Action* · 1.5 → *Marketplace item* · 2.1 → *Action* · 2.2 → *Action* |
| 2.4 | James · My Borrowing | 1.1 → *Borro tab* |
| 3.1 | Thomas · Push · new request | 1.1 → *Borro tab* · 2.4 → *Card* |
| 3.2 | Thomas · Borrow Requests | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* |
| 3.3 | Thomas · Borrow request expanded | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* |
| 3.4 | Thomas · James public profile | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* |
| 3.5 | Thomas · Credibility score info | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 3.4 → *Score* |
| 3.6 | Thomas · James all reviews | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 3.4 → *Copy* |
| 3.7 | Thomas · Accept James' request? (dialog) | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* |
| 3.8 | James · Push · request accepted | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 3.7 → *Action* |
| 3.9 | James · Request accepted | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 3.7 → *Action* · 3.8 → *3.8 James · Push · request accepted* |
| 4.1 | James · Propose handover | … 3.3 → *Action* · 3.7 → *Action* · 3.8 → *3.8 James · Push · request accepted* · 3.9 → *Action* |
| 4.2 | James · Pick-up dates (pop-up) | … 3.7 → *Action* · 3.8 → *3.8 James · Push · request accepted* · 3.9 → *Action* · 4.1 → *Pick-up row* |
| 4.3 | James · Pick-up times (pop-up) | … 3.8 → *3.8 James · Push · request accepted* · 3.9 → *Action* · 4.1 → *Pick-up row* · 4.2 → *Primary button* |
| 4.4 | James · Return dates (pop-up) | … 3.9 → *Action* · 4.1 → *Pick-up row* · 4.2 → *Primary button* · 4.3 → *Primary button* |
| 4.5 | James · Return times (pop-up) | … 4.1 → *Pick-up row* · 4.2 → *Primary button* · 4.3 → *Primary button* · 4.4 → *Primary button* |
| 4.6 | James · Pick on map | … 3.7 → *Action* · 3.8 → *3.8 James · Push · request accepted* · 3.9 → *Action* · 4.1 → *Pick on map button* |
| 4.7 | James · Times chosen | … 3.8 → *3.8 James · Push · request accepted* · 3.9 → *Action* · 4.1 → *Pick on map button* · 4.6 → *Use this location button* |
| 4.8 | James · Proposal sent | … 3.9 → *Action* · 4.1 → *Pick on map button* · 4.6 → *Use this location button* · 4.7 → *Send proposal button · Enabled* |
| 4.9 | James · Chat with Thomas | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* |
| 4.10 | James · Chat attachment menu | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *Message composer* |
| 4.11 | Thomas · Review proposal | … 4.1 → *Pick on map button* · 4.6 → *Use this location button* · 4.7 → *Send proposal button · Enabled* · 4.8 → *Banner text* |
| 4.12 | Thomas · Choose times (pop-up) | … 4.6 → *Use this location button* · 4.7 → *Send proposal button · Enabled* · 4.8 → *Banner text* · 4.11 → *Accept proposal* |
| 4.13 | Thomas · Request changes (branch) | … 4.6 → *Use this location button* · 4.7 → *Send proposal button · Enabled* · 4.8 → *Banner text* · 4.11 → *Request changes* |
| 4.14 | Both · Handover confirmed | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *chevron-left* |
| 5.1 | Thomas · Agreement sent | Demo menu (long-press the status bar) → All frames |
| 5.2 | James · Final Agreement | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *Action* |
| 5.2a | James · PayNow · Confirm payment (sheet) | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *Action* · 5.2 → *image 3* |
| 5.2b | James · PayNow · Scan to pay | … 3.3 → *Action* · 4.9 → *Action* · 5.2 → *image 3* · 5.2a → *Pay with PayNow* |
| 5.2c | James · PayNow · Processing payment | … 4.9 → *Action* · 5.2 → *image 3* · 5.2a → *Pay with PayNow* · 5.2b → *I've paid* |
| 5.2d | James · Payment successful | … 5.2 → *image 3* · 5.2a → *Pay with PayNow* · 5.2b → *I've paid* · 5.2c → *5.2c James · PayNow · Processing payment* |
| 5.2e | Both · Terms & Conditions | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *Action* · 5.2 → *Title link* |
| 5.2f | James · Apple Pay (sheet) [app only] | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *Action* · 5.2 → *Apple Pay button* |
| 5.3 | James · Lender care note | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *Action* · 5.2 → *Card* |
| 5.4 | James · Deposit info | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *Action* · 5.2 → *Deposit title row* |
| 5.5 | James · Deposit paid | … 5.2a → *Pay with PayNow* · 5.2b → *I've paid* · 5.2c → *5.2c James · PayNow · Processing payment* · 5.2d → *Continue* |
| 5.6 | James · Agreement submitted | … 5.2b → *I've paid* · 5.2c → *5.2c James · PayNow · Processing payment* · 5.2d → *Continue* · 5.5 → *Action* |
| 5.7 | Both · Timeline · agreed | … 5.2c → *5.2c James · PayNow · Processing payment* · 5.2d → *Continue* · 5.5 → *Action* · 5.6 → *Action* |
| 6.1 | Thomas · Drop-off · lender code | 1.1 → *Borro tab* · 2.4 → *Card* |
| 6.2 | Thomas · Lender code info (sheet) | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *info* |
| 6.3 | Thomas · Name the photo (sheet) | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* |
| 6.3a | Thomas · Name the back photo (sheet) | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* · 6.4 → *Frame* · 6.5 → *photo-box* |
| 6.3b | Thomas · Name the extra photo (sheet) | … 6.3 → *Action* · 6.4 → *Frame* · 6.5a → *Frame* · 6.6 → *photo-box* |
| 6.4 | Thomas · Front photo added | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* |
| 6.5 | Thomas · Back photo (empty) | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* · 6.4 → *Frame* |
| 6.5a | Thomas · Back photo added | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* · 6.4 → *Frame* |
| 6.6 | Thomas · Add additional photos | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* · 6.4 → *Frame* · 6.5a → *Frame* |
| 6.6a | Thomas · Extra photo added | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* · 6.4 → *Frame* |
| 6.7 | Thomas · Photo options (delete / upload / retake) | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* · 6.4 → *More horizontal* |
| 6.8 | Thomas · Edit photo name (sheet) | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* · 6.4 → *Photo requirement* |
| 6.9 | Thomas · Ready to submit? (sheet) | 1.1 → *Borro tab* · 2.4 → *Card* · 6.1 → *photo-box* · 6.3 → *Action* · 6.4 → *Frame* · 6.5a → *Action* |
| 6.10 | Thomas · Drop-off saved · share code | … 6.3 → *Action* · 6.4 → *Frame* · 6.5a → *Action* · 6.9 → *Action* |
| 6.10a | Both · Timeline · meet-up | … 6.4 → *Frame* · 6.5a → *Action* · 6.9 → *Action* · 6.10 → *Action* |
| 6.11 | James · Collection · enter lender code | … 6.5a → *Action* · 6.9 → *Action* · 6.10 → *Action* · 6.10a → *Action* |
| 6.12 | James · Wrong code | … 6.9 → *Action* · 6.10 → *Action* · 6.10a → *Action* · 6.11 → *type a wrong code* |
| 6.13 | James · Meet in person first (sheet) | … 6.9 → *Action* · 6.10 → *Action* · 6.10a → *Action* · 6.11 → *Copy* |
| 6.14 | James · Code verified | … 6.9 → *Action* · 6.10 → *Action* · 6.10a → *Action* · 6.11 → *type 6767* |
| 6.14a | James · Front photo added | … 6.10 → *Action* · 6.10a → *Action* · 6.11 → *type 6767* · 6.14 → *photo-box* |
| 6.14b | James · Back photo (empty) | … 6.10a → *Action* · 6.11 → *type 6767* · 6.14 → *photo-box* · 6.14a → *Frame* |
| 6.14c | James · Back photo added | … 6.10a → *Action* · 6.11 → *type 6767* · 6.14 → *photo-box* · 6.14a → *Frame* |
| 6.14d | James · Add additional photos | … 6.11 → *type 6767* · 6.14 → *photo-box* · 6.14a → *Frame* · 6.14c → *Frame* |
| 6.15 | James · Photo added | … 6.10a → *Action* · 6.11 → *type 6767* · 6.14 → *photo-box* · 6.14a → *Frame* |
| 6.16 | James · Photo options | … 6.10a → *Action* · 6.11 → *type 6767* · 6.14 → *photo-box* · 6.14a → *More horizontal* |
| 6.17 | James · Missing photos (sheet) | … 6.10 → *Action* · 6.10a → *Action* · 6.11 → *type 6767* · 6.14 → *Action* |
| 6.18 | James · Ready to submit? (sheet) | … 6.11 → *type 6767* · 6.14 → *photo-box* · 6.14a → *Frame* · 6.14c → *Action* |
| 6.19 | Both · Handover summary | … 6.14 → *photo-box* · 6.14a → *Frame* · 6.14c → *Action* · 6.18 → *Action* |
| 6.20 | Both · Timeline · ongoing | … 6.14a → *Frame* · 6.14c → *Action* · 6.18 → *Action* · 6.19 → *Action* |
| 7.1 | James · Return code + after photos | … 6.14c → *Action* · 6.18 → *Action* · 6.19 → *Action* · 6.20 → *Action* |
| 7.2 | Thomas · Enter borrower code | … 6.18 → *Action* · 6.19 → *Action* · 6.20 → *Action* · 7.1 → *Action* |
| 7.2a | Thomas · Front photo added | … 6.19 → *Action* · 6.20 → *Action* · 7.1 → *Action* · 7.2 → *photo-box* |
| 7.2b | Thomas · Back photo (empty) | … 6.20 → *Action* · 7.1 → *Action* · 7.2 → *photo-box* · 7.2a → *Frame* |
| 7.2c | Thomas · Back photo added | … 6.20 → *Action* · 7.1 → *Action* · 7.2 → *photo-box* · 7.2a → *Frame* |
| 7.2d | Thomas · Add additional photos | … 7.1 → *Action* · 7.2 → *photo-box* · 7.2a → *Frame* · 7.2c → *Frame* |
| 7.3 | Thomas · Return photo added | … 6.20 → *Action* · 7.1 → *Action* · 7.2 → *photo-box* · 7.2a → *Frame* |
| 7.4 | Thomas · Ready to submit? (sheet) | … 7.1 → *Action* · 7.2 → *photo-box* · 7.2a → *Frame* · 7.2c → *Action* |
| 7.5 | Both · Return confirmed | … 7.2 → *photo-box* · 7.2a → *Frame* · 7.2c → *Action* · 7.4 → *Action* |
| 7.6 | Both · Timeline · refund processing | … 7.2a → *Frame* · 7.2c → *Action* · 7.4 → *Action* · 7.5 → *Action* |
| 8.1 | James · Push · rate Thomas | Demo menu (long-press the status bar) → All frames |
| 8.2 | James · Rate Thomas | … 7.2c → *Action* · 7.4 → *Action* · 7.5 → *Action* · 7.6 → *Action* |
| 8.3 | James · Rate Thomas · filled | … 7.4 → *Action* · 7.5 → *Action* · 7.6 → *Action* · 8.2 → *Five star controls* |
| 8.4 | James · Review submitted | … 7.5 → *Action* · 7.6 → *Action* · 8.2 → *Five star controls* · 8.3 → *Action* |
| 8.5 | Thomas · Push · rate James | … 7.6 → *Action* · 8.2 → *Five star controls* · 8.3 → *Action* · 8.4 → *Thomas push banner* |
| 8.6 | Thomas · Rate James | … 8.2 → *Five star controls* · 8.3 → *Action* · 8.4 → *Thomas push banner* · 8.5 → *8.5 Thomas · Push · rate James* |
| 8.7 | Thomas · Review submitted | … 8.3 → *Action* · 8.4 → *Thomas push banner* · 8.5 → *8.5 Thomas · Push · rate James* · 8.6 → *Action* |
| 8.8 | Both · Timeline · deposit refunded | … 7.6 → *Action* · 8.2 → *Five star controls* · 8.3 → *Action* · 8.4 → *Action* |
| 8.9 | James · Profile | 1.1 → *You tab* |
| 9.1 | Thomas · My Lending · Active | 1.1 → *Lend tab* |
| 9.2 | Thomas · My Lending · Sort / Filter | 1.1 → *Lend tab* · 9.1 → *Sort and filter* |
| 9.3 | Thomas · My Lending · Past loans | 1.1 → *Lend tab* · 9.1 → *Archived tab* |
| 9.4 | Thomas · Past loans · Sort / Filter | 1.1 → *Lend tab* · 9.1 → *Archived tab* · 9.3 → *Sort and filter* |
| 9.5 | Thomas · Manage listing menu | 1.1 → *Lend tab* · 9.1 → *ellipsis* |
| 9.6 | Thomas · Paused listing | 1.1 → *Lend tab* · 9.1 → *ellipsis* |
| 9.7 | Thomas · Delete confirmation | 1.1 → *Lend tab* · 9.1 → *ellipsis* · 9.5 → *Listing action* |
| 9.8 | Thomas · List an Item · Step 1 photos | 1.1 → *Lend tab* · 9.1 → *Action* |
| 9.9 | Thomas · Step 2 details | 1.1 → *Lend tab* · 9.1 → *Action* · 9.8 → *Action* |
| 9.10 | Thomas · Step 3 pick-up | 1.1 → *Lend tab* · 9.1 → *Action* · 9.8 → *Action* · 9.9 → *Action* |
| 9.11 | Thomas · Step 4 availability | 1.1 → *Lend tab* · 9.1 → *Action* · 9.8 → *Action* · 9.9 → *Action* · 9.10 → *Action* |
| 9.12 | Thomas · Step 5 period | 1.1 → *Lend tab* · 9.1 → *Action* · 9.8 → *Action* · 9.9 → *Action* · 9.10 → *Action* · 9.11 → *Action* |
| 9.13 | Thomas · Step 6 deposit | … 9.9 → *Action* · 9.10 → *Action* · 9.11 → *Action* · 9.12 → *Action* |
| 9.14 | Thomas · Step 7 care | … 9.10 → *Action* · 9.11 → *Action* · 9.12 → *Action* · 9.13 → *Action* |
| 9.15 | Thomas · Step 8 terms | … 9.11 → *Action* · 9.12 → *Action* · 9.13 → *Action* · 9.14 → *Action* |
| 9.16 | Thomas · Listing preview | … 9.12 → *Action* · 9.13 → *Action* · 9.14 → *Action* · 9.15 → *Action* |
| 9.17 | Thomas · Steamer is live | … 9.13 → *Action* · 9.14 → *Action* · 9.15 → *Action* · 9.16 → *Action* |
| 10.1 | James · Report damage · incomplete | Demo menu (long-press the status bar) → All frames |
| 10.2 | James · Report damage · filled | Demo menu (long-press the status bar) → All frames |
| 10.3 | James · Damage tracker · submitted | Demo menu (long-press the status bar) → All frames |
| 10.4 | James · Damage tracker · evaluating | Demo menu (long-press the status bar) → All frames |
| 10.5 | James · Damage tracker · verifying | Demo menu (long-press the status bar) → All frames |
| 10.6 | Both · Timeline · damage | Demo menu (long-press the status bar) → All frames |
| 10.7 | Both · Timeline · repair | Demo menu (long-press the status bar) → All frames |
| 10.8 | Both · Post-Borro review · damage | Demo menu (long-press the status bar) → All frames |
| 10.9 | Both · Repair balance paid | Demo menu (long-press the status bar) → All frames |
| 10.10 | James · Push · borrowing cancelled | Demo menu (long-press the status bar) → All frames |
| 10.11 | James · Borrowing cancelled · alternatives | Demo menu (long-press the status bar) → All frames |
| 10.12 | James · Nearby alternatives | Demo menu (long-press the status bar) → All frames |
| 10.13 | James · Find new lender | Demo menu (long-press the status bar) → All frames |
| 11.1 | James · Item details · Borrow Later | Demo menu (long-press the status bar) → All frames |
| 11.2 | James · Borrow Later · pick dates | 1.1 → *Urgency toggle* · 1.2 → *sliders-horizontal* · 1.3 → *Filter option* · 1.4 → *Action* · 1.5 → *Marketplace item* · 2.1 → *Action* |
| 11.3 | James · Borrow Later · request sent | … 1.4 → *Action* · 1.5 → *Marketplace item* · 2.1 → *Action* · 11.2 → *Action* |
| 11.4 | James · Wishlist | 1.1 → *heart* |
| 11.5 | James · Ask Borro (AI chat) | 1.1 → *Lend tab* · 9.1 → *Requests shortcut* · 3.2 → *Copy* · 3.3 → *Action* · 4.9 → *Speech bubble* |

112 of 128 frames are reachable by tapping from 1.1; 16 only from the demo menu: 5.1, 8.1, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9, 10.10, 10.11, 10.12, 10.13, 11.1.
