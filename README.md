# Borro — SwiftUI prototype

A native SwiftUI iPhone app implementing the **Borro** design file
(`FRdguO9GdzR7f8EeSnaRNR`): a Singapore neighbourhood item-lending product.
All 13 Figma sections — **122 artboards** — are implemented as one interactive
prototype, and each artboard is directly reachable for review.

---

## Run it on your iPhone (free Apple ID, 5 minutes)

You need Xcode from the App Store and a USB cable.

1. **Open the project**
   ```bash
   open "Borro.xcodeproj"
   ```

2. **Pick your signing team**
   Xcode → blue **Borro** project icon → **Borro** target → **Signing &
   Capabilities** → tick *Automatically manage signing* → **Team** →
   *Add an Account…* → sign in with your Apple ID → select
   `Your Name (Personal Team)`.
   If the bundle id is rejected, change `com.borro.prototype` to something unique
   (e.g. `com.yourname.borro`) and pick a new team.

3. **Enable Developer Mode on the phone**
   iPhone → **Settings → Privacy & Security → Developer Mode → On** (iOS 16+),
   restart, plug in, tap **Trust**.

4. **Run**
   Select your iPhone in Xcode's toolbar and press **⌘R**.
   First launch: **Settings → General → VPN & Device Management → your Apple ID
   → Trust**, then open the app.

5. A free Apple ID install expires after **7 days** — plug in and press ⌘R again to
   renew. A paid developer account gives 1 year.

### Simulator
```bash
xcodebuild -project Borro.xcodeproj -scheme Borro -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath /tmp/DD build CODE_SIGNING_ALLOWED=NO \
  'EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets'
xcrun simctl boot "iPhone 17 Pro"; open -a Simulator
xcrun simctl install booted /tmp/DD/Build/Products/Debug-iphonesimulator/Borro.app
xcrun simctl launch booted com.borro.prototype
```
`EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets` is only needed when building from a
sandboxed shell (Apple's asset-catalog agent needs simulator services). In Xcode
itself, just press Run.

---

## Reviewing the 13 designs on the phone

Open the **You** tab → **Figma design index**. It lists all 13 sections and their
122 artboards; tap any artboard to open that exact screen in the app.

| # | Section | Artboards | Code |
|---|---|---|---|
| 1 | Discover | 5 | `Features/Home/HomeView.swift` |
| 2 | Request | 4 | `Features/Flows/RequestFlow.swift` |
| 3 | Lender decides | 9 | `Features/Flows/LenderDecisionFlow.swift` |
| 4 | Schedule & chat | 14 | `Features/Flows/ScheduleChatFlow.swift` |
| 5 | Lending agreement | 6 | `Features/Flows/AgreementFlow.swift` |
| 6 | Handover (codes + photos) | 20 | `Features/Flows/HandoverFlow.swift` |
| 6b | Photo steps per pill | 12 | `Features/Flows/HandoverFlow.swift` |
| 6c | Timeline stages | 2 | `Features/Flows/HandoverFlow.swift` |
| 7 | Return | 6 | `Features/Flows/ReturnFlow.swift` |
| 8 | Reviews & refund | 9 | `Features/Flows/ReviewsFlow.swift` |
| 9 | My Lending & List an Item | 17 | `Features/Flows/LendingFlow.swift` |
| 10 | Damage & cancellation | 13 | `Features/Flows/DamageFlow.swift` |
| 11 | Borrow Later · Wishlist · AI chat | 5 | `Features/Flows/OtherScreensFlow.swift` |

Deep links (used by the QA harness, handy for demos):
```bash
xcrun simctl launch booted com.borro.prototype -uiScreen 691-4767   # one artboard
xcrun simctl launch booted com.borro.prototype -uiFlow handover     # a flow root
xcrun simctl launch booted com.borro.prototype -uiFlowMap           # the index
xcrun simctl launch booted com.borro.prototype -uiTab lend          # a tab
```

---

## What is where

```
Borro/
├── App/
│   ├── BorroApp.swift        entry point, font registration
│   ├── AppRouter.swift       tabs, routes, FlowHost, public profile
│   └── BorroStore.swift      scenario fixtures (Thomas lends James a steamer)
├── DesignSystem/
│   ├── Tokens.swift          BColor / BSpace / BRadius / BMetric — from Figma
│   ├── Fonts.swift           Inter (bundled, registered at launch)
│   ├── Photos.swift          BPhoto catalog of all 43 Figma bitmaps
│   ├── Kit.swift             app bar, tab bar, buttons, fields, chips, item card…
│   └── FlowKit.swift         code boxes, photo tiles, timeline, chat, map, push mock…
├── Models/Models.swift       Person, Item, BorrowRequest, TimelineStage, Review
├── Features/
│   ├── Home/                 section 1
│   ├── Flows/                sections 2–11 (one file per flow)
│   ├── FlowMap/              generated index of the 13 sections
│   └── You/                  You tab
└── Resources/
    ├── Fonts/                Inter Regular/Medium/SemiBold/Bold/ExtraBold
    └── Photos/               43 photos + transparent Borro wordmark
```

Design artefacts pulled from Figma (read-only inputs):

```
design/figma/
├── nodes.json                full node trees of the 13 sections
├── spec/<section>.md         flattened spec per section
├── frames/<slug>.png|.md     one crop + spec per artboard (122)
└── png/                      full section renders
```

---

## Re-pulling the design / QA harness

```bash
# Figma pull (needs a read-only personal access token in .figma_token)
node tools/figma_pull.mjs
python3 tools/build_frame_assets.py      # per-artboard crops + specs

# Screenshot every artboard through the app
tools/qa_all.sh                          # all 122 -> docs/screens/qa
tools/qa_all.sh 691-4767 701-203         # selected ones

# Side-by-side Figma vs SwiftUI
python3 tools/compare.py                 # -> docs/screens/compare
```

`.figma_token` is git-ignored. Revoke/rotate it in Figma → Settings → Security.

---

## Known deviations

- **Device size**: Figma frames are 393×852 (iPhone 15/16 class). The prototype
  uses 20pt side padding and flexible heights, so it adapts to 402×874 (iPhone 17)
  and other sizes; vertical rhythm differs slightly from the 852pt artboards
  because the tab bar and home indicator occupy more/less space.
- **Fonts**: the file uses Inter (bundled). Two areas specify Roboto Mono in Figma
  (calendar numerals, timeline milestones) and use Inter here.
- **Push notifications** (3.1, 3.8, 8.1, 8.5, 10.10) are rendered as an in-app
  lock-screen mock, since the prototype cannot receive real APNs pushes.
- **Icons**: the handshake glyph in the Figma tab bar has no SF Symbol equivalent;
  a similar exchange icon is substituted.
- The prototype is light-mode only, iPhone-first, and all data is in-memory.
