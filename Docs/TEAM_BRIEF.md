# Borro SwiftUI — team brief

You are implementing part of a pixel-faithful SwiftUI prototype of **Borro** (a
Singapore neighbourhood item-lending app), transcribed from a 13-section Figma file.

Everything you need is already on disk. Do **not** call the Figma API; the design
has been pulled into `design/figma/`.

---

## 1. Where the design lives

```
design/figma/
├── frames/
│   ├── <slug>.png     ← exact @2x render of one artboard (393x852)
│   ├── <slug>.md      ← node tree: sizes, coordinates, fills, fonts, spacing
│   ├── <slug>.json    ← metadata: name, section, text content, image refs
│   └── index.json     ← 13 sections × 122 artboards
├── spec/<section>.md  ← whole-section spec
└── images/            ← original Figma image fills
```

Slug format is the Figma node id with `:` replaced by `-`, e.g. `691-4139`.
Open the `.png` crop first — it is the ground truth. Use the `.md` for exact
sizes, colours, radii and copy. Never invent copy: every string exists in the spec.

The app already ships every photo from the file in `Borro/Resources/Photos/`.
Use `BPhoto` accessors (`.steamer`, `.avatar_thomas`, `.damage1`, …) or
`BPhoto(key: "...")`. Contact sheet: `docs/screens/figma-photo-sheet.jpg`.

---

## 2. App architecture

- `BorroApp` → `AppShell` (`Borro/App/AppRouter.swift`) → tab roots
  (`HomeView`, `MyBorrowingTabView`, `LendingTabView`, `YouTabView`).
- `AppShell` owns one `NavigationStack`; routes are `BRoute`:
  `.home(screen:)`, `.flow(FlowID, screen:)`, `.person(Person)`, `.flowMap`.
- `FlowHost` maps `FlowID` → your flow view struct, passing `startScreen: String?`.
- Global scenario state: `BorroStore` (`@EnvironmentObject`), fixtures in
  `BPeople` / `BItems` (Thomas = lender, James = borrower, Garment Steamer item).
- Every screen in the design is an iPhone frame **393 × 852**; build for that width
  with `BSpace.screen` (20pt) side padding. Content width is 353.

### Your flow must be a self-contained state machine

```swift
struct MyFlow: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: BorroStore

    var startScreen: String? = nil
    @State private var stack: [String] = []          // artboard slugs
    @State private var ...                            // local state for each variant

    var body: some View {
        ZStack { switch current { case "691-4767": ...; default: ... } }
            .bBackground()
            .onAppear { if let s = startScreen, stack.isEmpty { stack = [s] } else if stack.isEmpty { stack = ["<entry slug>"] } }
    }
    private var current: String { stack.last ?? "<entry slug>" }
    private func go(_ slug: String) { withAnimation(.easeOut(duration: 0.2)) { stack.append(slug) } }
    private func back() { if stack.count > 1 { stack.removeLast() } else { router.pop() } }
}
```

- Every `BAppBar(showsBack: true, backAction: back)` uses `back()`.
- Pop-ups are **sheets** (`.sheet` + `BSheetSurface`) or overlay states, not separate
  pushed screens.
- Branch variants (e.g. "wrong code", "request changes") are states with a second
  render path inside the same screen.
- `startScreen` must deep-link to the exact artboard (used for review screenshots).
  If a screen is a sheet state, open the parent screen with the sheet presented.

---

## 3. Design system — use it, don't reinvent it

`Borro/DesignSystem/`:

| File | Contains |
|---|---|
| `Tokens.swift` | `BColor`, `BSpace`, `BRadius`, `BMetric` |
| `Fonts.swift` | `BFont` (Inter, registered at launch) |
| `Photos.swift` | `BPhoto`, `BImageView`, `BAvatarView`, `BLogoMark` |
| `Kit.swift` | app bar, tab bar, buttons, fields, chips, cards, ratings, sheets, rows |
| `FlowKit.swift` | code boxes, photo tiles, timeline, chat bubbles, map, push mock, confirmation, step pills, calendar strip |

Key components (read the source for full signatures):

```swift
BAppBar(title: "Item description", subtitle: "Need it Now · 120 m away") { trailing }
BButtonStyle(kind: .primary/.secondary/.ghost/.destructive, height:, fullWidth:, pill:)
BButtonLabel("Borrow Now", icon: "bolt.fill")
BField(placeholder:text:icon:)
BSearchRow(text:placeholder:onSearch:)
BChip(title:icon:selected:)
BFilterChip(title:value:icon:hasChevron:onTap:)
BUrgencyToggle(isOn:onToggle:)
BTag(text:icon:tint:)
BSectionHeader(title:subtitle:actionTitle:action:)
BStars(rating:reviews:)
BStarPicker(rating:)
BAvatarView(photo:initials:size:)
BOwnerRow(person:size:)
BItemCard(item:saved:onSave:onTap:showsDistance:)
BMenuRow(icon:title:subtitle:value:showsChevron:)
BDivider()
BSheetHandle/BSheetHeader(title:subtitle:onClose:)/BSheetSurface { }
BPillSelector(items:title:selection:)
BInfoBanner(icon:text:tint:)
BCodeBoxes(code:length:error:)
BPhotoTile(photo:caption:height:showsRemove:onTap:)
BTimelineList(stages:)
BChatBubble(message:)/BChatComposer(text:onSend:)
BMapCard(label:subtitle:height:)
BPushScreen(title:message:onOpen:)
BConfirmationPanel(icon:title:message:primaryTitle:primaryAction:secondaryTitle:secondaryAction:)
BStepPill(number:state:label:)
BCalendarStrip(days:busyDays:selected:onTap:)
```

Styling rules:

- Backgrounds: `BColor.bg` (`#F7F8F6`); cards `BColor.surface` white, radius
  `BRadius.card` (12); photos radius 10.
- Ink `#14231C`; secondary `#68766E`; brand `#2341DD`; strokes `#E2E8E1`.
- Fonts: Inter only. `BFont.pageTitle` 21 bold app-bar heading, `BFont.caption` 11
  subtitle, `BFont.body` 14, `BFont.labelSemibold` 12, `BFont.micro` 10.
- Buttons are 46pt tall pills; primary blue, secondary white with stroke.
- Never hardcode a hex that is not in the Figma spec; if you need a new token, add it
  locally in your own file rather than editing `Tokens.swift`.

Shared-file ownership: **read-only** for you. Do not modify
`Tokens.swift`, `Kit.swift`, `FlowKit.swift`, `Fonts.swift`, `Photos.swift`,
`Models.swift`, `BorroStore.swift`, `AppRouter.swift`, `HomeView.swift`,
`YouTabView.swift`, `FlowMap/**`, or any other flow file. If you need a shared
component, define it privately inside your own file.

---

## 4. Build, run, screenshot

Always build with your own derived data path (parallel teammates):

```bash
xcodebuild -project Borro.xcodeproj -scheme Borro -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,id=<YOUR_UDID>' -configuration Debug \
  -derivedDataPath .build/DD-<yourname> build CODE_SIGNING_ALLOWED=NO \
  'EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets'
```

`EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets` is required: the sandbox cannot run
Apple's asset-catalog agent. The app icon only matters for the final device build.

Screenshot harness (use it to compare against Figma crops):

```bash
tools/qc.sh <yourname> 691-4767 691-4822 ...   # builds, installs, screenshots
```

Outputs `docs/screens/qc/<slug>.png`. Open both that and
`design/figma/frames/<slug>.png` and iterate until they match.

---

## 5. Definition of done (per flow)

1. Every artboard in your sections is reachable, in order, from the flow's entry
   screen, with pop-ups as sheets and branches as states.
2. `startScreen` opens any artboard directly.
3. Copy, photos, colours, type sizes and spacing match the Figma crops; no lorem.
4. Build succeeds with zero errors and your files are the only ones you changed.
5. Report back: files touched, artboards covered, anything you could not match.

Quality bar: someone comparing your screen to the Figma crop side-by-side should
see the same layout, not merely a similar one.
