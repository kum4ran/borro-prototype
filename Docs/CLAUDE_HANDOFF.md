You are Claude Code working in the repo at:

    /Users/matth/Documents/Borro Working Prototype

Goal: take this existing SwiftUI prototype and make every screen match the Figma design file exactly, then make sure it still builds and installs on the user's own iPhone. The app is already implemented end-to-end; your job is fidelity, consistency, and verifying the build — not starting over.

Read these first, in order:
- README.md            (how to run, architecture, deep links, QA tooling)
- docs/QA.md           (coverage of all 122 artboards, known deviations)
- docs/TEAM_BRIEF.md   (design sources, state-machine pattern, component API)

────────────────────────────────────────────────────────
1. WHAT EXISTS (do not rebuild from scratch)
────────────────────────────────────────────────────────
The Figma file is FRdguO9GdzR7f8EeSnaRNR ("Borro"). Its 13 linked "designs" are flow sections containing 122 iPhone artboards (393×852). All 122 are implemented:

  1  Discover                 5 artboards   Borro/Features/Home/HomeView.swift
  2  Request                  4             Borro/Features/Flows/RequestFlow.swift
  3  Lender decides           9             Borro/Features/Flows/LenderDecisionFlow.swift
  4  Schedule & chat         14             Borro/Features/Flows/ScheduleChatFlow.swift
  5  Lending agreement        6             Borro/Features/Flows/AgreementFlow.swift
  6  Handover                20             Borro/Features/Flows/HandoverFlow.swift
  6b Photo steps             12             Borro/Features/Flows/HandoverFlow.swift
  6c Timeline stages          2             Borro/Features/Flows/HandoverFlow.swift
  7  Return                   6             Borro/Features/Flows/ReturnFlow.swift
  8  Reviews & refund         9             Borro/Features/Flows/ReviewsFlow.swift
  9  My Lending / List item  17             Borro/Features/Flows/LendingFlow.swift
 10  Damage & cancellation   13             Borro/Features/Flows/DamageFlow.swift
 11  Borrow Later/Wishlist/AI 5             Borro/Features/Flows/OtherScreensFlow.swift

~13,000 lines of flow code plus a shared design system. Last verified state: `xcodebuild` succeeds with zero errors.

Design inputs already pulled from Figma (read-only, ground truth):
- design/figma/frames/<slug>.png   exact @2x render of one artboard (slug = Figma node id, ":" → "-", e.g. 691-4767)
- design/figma/frames/<slug>.md    node tree: coordinates, sizes, radii, fills, fonts, exact copy
- design/figma/frames/<slug>.json  metadata (name, section, text, image refs)
- design/figma/frames/index.json   13 sections × 122 artboards
- design/figma/spec/<section>.md   whole-section spec
- design/figma/nodes.json          full node trees
- design/figma/images/             43 source photos (+ index.json)
- Borro/Resources/Photos/          the same photos with semantic names (used via BPhoto)
- .figma_token                     read-only Figma token (git-ignored) for re-pulling

Architecture:
- Borro/App/AppRouter.swift — AppShell (tabs Home/Borro/Lend/You), NavigationStack, BRoute, FlowHost mapping FlowID → flow view, -uiScreen/-uiFlow/-uiFlowMap/-uiTab deep links.
- Borro/App/BorroStore.swift — scenario fixtures (James borrows Thomas's Garment Steamer) + shared state.
- Borro/DesignSystem/Tokens.swift — BColor, BSpace, BRadius, BMetric (all values from Figma).
- Borro/DesignSystem/Fonts.swift — Inter (bundled, registered at launch).
- Borro/DesignSystem/Photos.swift — BPhoto catalog + BImageView/BAvatarView/BLogoMark.
- Borro/DesignSystem/Kit.swift — BAppBar, BTabBar, buttons, fields, chips, BItemCard, BStars, sheets, rows.
- Borro/DesignSystem/FlowKit.swift — BCodeBoxes, BPhotoTile, BTimelineList, BChatBubble/Composer, BMapCard, BPushScreen, BConfirmationPanel, BStepPill, BCalendarStrip.
- Borro/Models/Models.swift — Person, Item, BorrowRequest, TimelineStage, Review.
- Each flow is a self-contained state machine keyed on artboard slug; pop-ups are sheet/overlay states, branches are states. Every flow accepts `startScreen: String?` and must keep doing so.

────────────────────────────────────────────────────────
2. NON-NEGOTIABLE CONTRACTS
────────────────────────────────────────────────────────
- The Figma crop is the visual truth. Use <slug>.md for exact px/hex/copy. Never invent copy, dates, names, prices or codes.
- Every artboard must stay reachable and directly openable via the slug deep link (-uiScreen <slug>). Do not remove startScreen handling.
- Keep the build green after every batch of edits.
- Shared design-system files (Tokens/Fonts/Photos/Kit/FlowKit/Models/Store/AppRouter) may be improved, but if you change a shared API you must fix every call site in the same change. Prefer consolidating one-off local components into DesignSystem over adding more of them.
- Inter only (5 weights bundled). Two places are Roboto Mono in Figma (calendar numerals, timeline milestones) — keep Inter and leave the documented deviation unless you also bundle Roboto Mono legally.
- Light mode only; iPhone portrait. Figma is 393×852; device may be 402×874 — keep 20pt side padding and fixed component heights, and verify safe areas.
- Screens draw their own in-flow 78pt bottom nav (Figma artboards include it); AppShell hides the root tab bar on pushed routes. Don't double it.

────────────────────────────────────────────────────────
3. BUILD / RUN / VERIFY
────────────────────────────────────────────────────────
Build (works in a sandboxed shell; always put DerivedData in /tmp, never in the workspace):

    xcodebuild -project Borro.xcodeproj -scheme Borro -sdk iphonesimulator \
      -destination 'generic/platform=iOS Simulator' -configuration Debug \
      -derivedDataPath /tmp/DD-claude build CODE_SIGNING_ALLOWED=NO \
      'EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets'

`EXCLUDED_SOURCE_FILE_NAMES=Assets.xcassets` is required outside Xcode (Apple's asset-catalog agent needs simulator services). In Xcode.app a normal Run includes the app icon.

Run in simulator:

    xcrun simctl boot "iPhone 17 Pro"; open -a Simulator
    xcrun simctl install booted /tmp/DD-claude/Build/Products/Debug-iphonesimulator/Borro.app
    xcrun simctl launch booted com.borro.prototype

Visual QA harness (the main way to find diffs):

    tools/qa_all.sh                 # build once + screenshot all 122 artboards → docs/screens/qa/<slug>.png
    tools/qa_all.sh 691-4767        # subset by slug substring
    python3 tools/compare.py        # Figma vs SwiftUI side-by-side → docs/screens/compare/<slug>.jpg

The comparison images already exist for all 122 artboards. Work section by section: open docs/screens/compare/<slug>.jpg next to design/figma/frames/<slug>.md, list concrete diffs (type size, spacing, colour, copy, missing element, clipping), fix, rebuild, re-screenshot, repeat.

Starting on the user's iPhone (they do the signing):
- Xcode → Borro target → Signing & Capabilities → Automatically manage signing → choose their Personal Team (free Apple ID), change bundle id if needed.
- iPhone → Settings → Privacy & Security → Developer Mode → On, trust the computer, then Run (⌘R); trust the developer cert on first launch.
- Free-account installs expire after 7 days (re-run to renew).

────────────────────────────────────────────────────────
4. KNOWN GAPS TO FIX (audited; prioritise in this order)
────────────────────────────────────────────────────────
1. Bottom-nav active state per artboard. Each flow renders its own BTabBar; several screens highlight the wrong tab (e.g. 691-4767 item details currently highlights Home, Figma highlights Borro). Audit all 122: section → expected tab: 1 → Home; 2,3,4,7,8 (borrower) → Borro; 5,6,6b,6c (lender/borrower) → Lend for lender screens, Borro for James; 9 → Lend; 8.9/You → You. Drive it from the artboard slug.
2. Push-notification mocks. BPushScreen is generic ("Saturday, 17 October", no identity line). Make 691-5139 (3.1), 700-520 (3.8), 703-3018 (8.1), 703-3129 (8.5), 708-2421 (10.10) match their crops: correct date/time, sender identity + credibility line, title/body, "Tap to respond"/swipe affordance, correct app-icon mark.
3. Logo. The bundled logo is now a transparent PNG (Borro/Resources/Photos/logo_borro.png) exposed as BLogoMark(width: 72). Replace remaining hand-drawn text wordmarks (ReturnFlow, ReviewsFlow, DamageFlow, HandoverFlow etc.) with BLogoMark so all app bars match Figma.
4. Component fragmentation. Teammates added local variants (RQ*, LPhoto, OPhoto, LWordmark, local code boxes / step pills / photo cards / star pickers / tab bars / push mocks) because shared versions diverged from crops. Consolidate the correct geometry into DesignSystem (BCodeBoxes 58×60 r10 40pt digits, BStarPicker thin-outline/gold fill, photo cards, in-flow tab bar) and delete local duplicates; then re-verify all affected screens.
5. Sheets and fixed heights. Section 5 care-note/deposit-info sheets and section 6 sheets are auto-sized vs Figma's fixed heights; match spec padding/heights. Also check safe-area/bottom anchoring (sheets should reach the screen bottom where Figma does).
6. Vertical rhythm and clipping. Look for: images bleeding outside frames, cards with overflowing long text, clipped labels, wrong card heights, missing dividers, off-by-a-few-point gaps. The iOS 26 tab bar/safe areas make the stack ~10–20pt taller than Figma's 852pt artboard — compensate per screen, don't rely on global offsets.
7. Section 6/6b/6c (40 artboards) — the largest section; it is code-complete but was never device-screenshot-verified. Do a full pass.
8. Data/identity consistency with Figma: item 2.1 shows owner as "Thomas" in Figma but "Thomas Lim" in code; audit names, codes ("6767"/"1234"/"8482"), dates (Oct 2026), prices ($4/day, $10 deposit), addresses (Block A Security Desk, Bencoolen St).
9. Icon substitutions: SF "handshake" is unavailable on this runtime and falls back to arrows. Draw a small custom handshake Shape if exactness matters.
10. Anything the comparison images show as visibly different. Treat each of the 122 as a checklist item.

────────────────────────────────────────────────────────
5. ENVIRONMENT TRAPS (important)
────────────────────────────────────────────────────────
- iCloud eviction: this folder lives in iCloud Drive. When the disk is tight, macOS evicts file contents ("dataless" APFS state). Then reads hang/time out (errno 60) — including Xcode builds. Check with: `stat -f %Sf <file>` (look for "compressed,dataless"). Repair with:
      cp -c <file> /tmp/x && cp /tmp/x <file> && rm /tmp/x
  or run `tools/materialize.sh` if present. Best fix: free several GB and/or move the project out of iCloud (e.g. ~/Developer/Borro) before working. Do not run bulk copy-back while another process is writing.
- Disk: the machine had < 4 GB free; use /tmp for DerivedData and don't create large files in the repo.
- Build products inside the iCloud folder cause massive I/O stalls. Always `-derivedDataPath /tmp/...`.
- One simulator at a time; `tools/qa_all.sh` creates/reuses a "Borro-QA" device.
- Never commit or echo `.figma_token`.

────────────────────────────────────────────────────────
6. DEFINITION OF DONE
────────────────────────────────────────────────────────
- `xcodebuild` succeeds with zero errors (same command as above).
- All 122 comparisons reviewed; each screen either matches its Figma crop or has a documented, justified deviation.
- Every artboard still opens via `-uiScreen <slug>`; the flow walkthroughs still work end-to-end.
- App builds normally in Xcode (with Assets.xcassets) and can be installed on the user's iPhone via their Personal Team.
- Update docs/QA.md with what changed and any remaining gaps; update README if commands/architecture changed.
- Report back: per-section diffs fixed, remaining gaps, build status, and the exact commands used.

────────────────────────────────────────────────────────
7. START HERE
────────────────────────────────────────────────────────
1. Read README.md, docs/QA.md, docs/TEAM_BRIEF.md.
2. Check for dataless files (see trap above) and materialise if needed.
3. Build once with the command in §3; confirm zero errors.
4. Run tools/qa_all.sh and python3 tools/compare.py (if evidence is stale).
5. Start with section 1 + section 2 comparisons (most visible screens), then work through sections 3→11, fixing nav states, push mocks and the logo first (they repeat everywhere).
6. Re-run QA, update docs, report.
