import SwiftUI

// MARK: - Section 10 · Damage and cancellation (edge cases)
//
// Figma node 708:1741 — 13 artboards, transcribed from design/figma/frames/.
// Entry screen is 10.1 (Report damage). The flow is a self-contained state
// machine; `startScreen` deep-links straight to any artboard (the QA harness
// launches the app with `-uiScreen <slug>`).
//
// Journey:
//   10.1/10.2 report form → 10.3 submitted → 10.4 evaluating → 10.5 verifying
//   → 10.6 timeline · damage → 10.7 timeline · repair → 10.8 post-Borro review
//   → 10.9 balance paid → 10.10 push · cancelled → 10.11 cancelled borrowing
//   → 10.12 nearby alternatives → 10.13 find new lender.
//
// The tracker frames are time-based backend states, so in the prototype the
// user advances the case by tapping the status notice / the primary action.

// MARK: Slug table

private enum DSlug {
    static let report            = "708-1742"
    static let reportFilled      = "708-1842"
    static let trackerSubmitted  = "708-1942"
    static let trackerEvaluating = "708-2017"
    static let trackerVerifying  = "708-2089"
    static let timelineDamage    = "708-2160"
    static let timelineRepair    = "708-2234"
    static let postReview        = "708-2298"
    static let balancePaid       = "708-2371"
    static let pushCancelled     = "708-2421"
    static let cancelledAlts     = "708-2443"
    static let nearbyAlts        = "708-2513"
    static let findNewLender     = "708-2598"

    static let all: [String] = [
        report, reportFilled, trackerSubmitted, trackerEvaluating, trackerVerifying,
        timelineDamage, timelineRepair, postReview, balancePaid, pushCancelled,
        cancelledAlts, nearbyAlts, findNewLender
    ]
}

// MARK: Local palette (hex values read from the section-10 frames)

private enum DColor {
    static let greenInk     = Color(hex: 0x1E8E5A)
    static let greenSoft    = Color(hex: 0xE8F4EC)
    static let redInk       = Color(hex: 0xD64545)
    static let redSoft      = Color(hex: 0xFDECE9)
    static let chipFill     = Color(hex: 0xEDF0EC)
    static let disabledFill = Color(hex: 0xDDE2DE)
    static let lendingTag   = Color(hex: 0xEAF0FF)
    static let warningSoft  = Color(hex: 0xFFF3D9)
}

// MARK: Flow state machine

struct DamageFlow: View {
    @EnvironmentObject private var router: AppRouter
    var startScreen: String? = nil

    @State private var stack: [String] = []
    @State private var detail = ""
    @State private var damageLocation = "Left side"
    @State private var damageType = "Dent"

    private static let filledDescription = "The steamer slipped against the table edge. There is a dent on the left side of the body. It still powers on."

    var body: some View {
        ZStack {
            switch current {
            case "708-1742", "708-1842":          // 10.1 / 10.2 report damage
                reportScreen
            case "708-1942":                      // 10.3 tracker · submitted
                SubmittedTrackerScreen(back: back, next: advanceTracker)
            case "708-2017":                      // 10.4 tracker · evaluating
                ProgressTrackerScreen(stage: 1, back: back, next: advanceTracker)
            case "708-2089":                      // 10.5 tracker · verifying
                ProgressTrackerScreen(stage: 2, back: back, next: advanceTracker)
            case "708-2160":                      // 10.6 timeline · damage
                TimelineDamageScreen(
                    back: back,
                    onTrack: { go(DSlug.trackerEvaluating) },
                    onReady: { go(DSlug.timelineRepair) }
                )
            case "708-2234":                      // 10.7 timeline · repair
                TimelineRepairScreen(
                    back: back,
                    onOutcome: { go(DSlug.postReview) }
                )
            case "708-2298":                      // 10.8 post-Borro review · damage
                PostBorroReviewScreen(
                    back: back,
                    onPay: { go(DSlug.balancePaid) }
                )
            case "708-2371":                      // 10.9 repair balance paid
                BalancePaidScreen(back: back, onDone: { go(DSlug.pushCancelled) })
            case "708-2421":                      // 10.10 push · borrowing cancelled
                BorrowingCancelledPush(onOpen: { go(DSlug.cancelledAlts) })
            case "708-2443":                      // 10.11 borrowing cancelled
                CancelledAlternativesScreen(
                    back: back,
                    onSeeAlternatives: { go(DSlug.nearbyAlts) },
                    onRequest: { go(DSlug.findNewLender) }
                )
            case "708-2513":                      // 10.12 nearby alternatives
                NearbyAlternativesScreen(
                    back: back,
                    onFindLender: { go(DSlug.findNewLender) },
                    onRequest: { go(DSlug.findNewLender) }
                )
            case "708-2598":                      // 10.13 find new lender
                FindNewLenderScreen(back: back)
            default:
                reportScreen
            }
        }
        .bBackground()
        .onAppear(perform: bootstrap)
    }

    // MARK: Navigation

    private var current: String { stack.last ?? DSlug.report }

    private var reportScreen: some View {
        ReportDamageScreen(
            detail: $detail,
            location: $damageLocation,
            damageType: $damageType,
            back: back,
            onSubmit: { go(DSlug.trackerSubmitted) }
        )
    }

    private func bootstrap() {
        guard stack.isEmpty else { return }
        if let start = startScreen, DSlug.all.contains(start) {
            stack = [start]
            if start == DSlug.reportFilled { detail = Self.filledDescription }
        } else {
            stack = [DSlug.report]
        }
    }

    private func go(_ slug: String) {
        withAnimation(.easeOut(duration: 0.2)) { stack.append(slug) }
    }

    private func replaceCurrent(with slug: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            if stack.isEmpty { stack = [slug] } else { stack[stack.count - 1] = slug }
        }
    }

    private func back() {
        if stack.count > 1 {
            withAnimation(.easeOut(duration: 0.2)) { _ = stack.removeLast() }
        } else {
            router.pop()
        }
    }

    private func advanceTracker() {
        switch current {
        case "708-1942": replaceCurrent(with: DSlug.trackerEvaluating)
        case "708-2017": replaceCurrent(with: DSlug.trackerVerifying)
        default:         go(DSlug.timelineDamage)
        }
    }
}

// MARK: - 10.1 / 10.2 · Report damage (incomplete / filled)

private struct ReportDamageScreen: View {
    @Binding var detail: String
    @Binding var location: String
    @Binding var damageType: String
    var back: () -> Void
    var onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Report Damage",
                subtitle: "Garment Steamer · Thomas",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Show us what happened. Clear photos help both sides reach a fair outcome.")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    evidenceGrid

                    Button(action: {}) {
                        Text("+ Add another angle")
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.brand)
                    }
                    .buttonStyle(.plain)

                    labelledChips(
                        title: "Where is the damage?",
                        rows: [
                            ["Top", "Bottom", "Front", "Back", "Left side"],
                            ["Right side", "Lens/Screen", "Other"]
                        ],
                        selection: $location
                    )

                    labelledChips(
                        title: "What kind of damage?",
                        rows: [
                            ["Dent", "Scratch", "Crack", "Not working"],
                            ["Missing part", "Other"]
                        ],
                        selection: $damageType
                    )

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Description")
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.ink)
                        DamageDescriptionField(text: $detail)
                    }
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: onSubmit) {
                Text("Report to Thomas")
            }
            .buttonStyle(DButtonStyle(kind: detail.isEmpty ? .disabled : .primary))
            .disabled(detail.isEmpty)
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }

    private var evidenceGrid: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                AngleTile(photo: .projectorSide, label: "Front")
                AngleTile(photo: .speakerDark, label: "Back")
                AngleTile(photo: .speakerDark, label: "Left")
            }
            HStack(spacing: 8) {
                AngleTile(photo: .projectorSide, label: "Right")
                AngleTile(photo: .speakerDark, label: "Top")
                AngleTile(photo: .speakerDark, label: "Bottom")
            }
        }
    }

    private func labelledChips(title: String, rows: [[String]], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: 6) {
                        ForEach(rows[rowIndex], id: \.self) { item in
                            SelectableChip(
                                text: item,
                                isOn: selection.wrappedValue == item,
                                action: { selection.wrappedValue = item }
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 10.3 · Damage tracker · submitted

private struct SubmittedTrackerScreen: View {
    var back: () -> Void
    var next: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Damage report status",
                subtitle: "Garment Steamer · Thomas",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DNotice(
                        title: "Your report is being reviewed",
                        message: "We’ve shared your evidence with Thomas. We’ll keep both of you updated.",
                        titleColor: .black
                    )
                    .contentShape(Rectangle())
                    .onTapGesture(perform: next)

                    DCard {
                        HStack(spacing: 12) {
                            BImageView(photo: BPhoto(key: "photo_7ff1a7e325"), cornerRadius: 10)
                                .frame(width: 80, height: 80)
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Dent on steamer body")
                                    .font(BFont.bold(16))
                                    .foregroundStyle(BColor.ink)
                                Text("Reported 19 Oct 2026 · BR-20481")
                                    .font(BFont.regular(12))
                                    .foregroundStyle(BColor.inkSecondary)
                                DChip(text: "Left side · Dent", fg: DColor.greenInk, bg: DColor.greenSoft)
                            }
                            Spacer(minLength: 0)
                        }
                    }

                    DCard {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(Self.checkpoints.enumerated()), id: \.offset) { index, item in
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(index == 0 ? BColor.brand : DColor.chipFill)
                                        Text("\(index + 1)")
                                            .font(BFont.regular(13))
                                            .foregroundStyle(index == 0 ? .white : BColor.inkSecondary)
                                    }
                                    .frame(width: 30, height: 30)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.title)
                                            .font(BFont.bold(15))
                                            .foregroundStyle(index == 0 ? BColor.ink : BColor.inkSecondary)
                                        if let subtitle = item.subtitle {
                                            Text(subtitle)
                                                .font(BFont.regular(12))
                                                .foregroundStyle(BColor.brand)
                                        }
                                    }
                                    Spacer(minLength: 0)
                                }
                                .frame(height: 52)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture(perform: next)

                    DNotice(
                        title: "Next update expected by 21 Oct",
                        message: "You can continue chatting with Thomas while we review the records.",
                        titleColor: .black
                    )
                    .contentShape(Rectangle())
                    .onTapGesture(perform: next)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: next) {
                Text("Chat with Thomas")
            }
            .buttonStyle(DButtonStyle())
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }

    private struct Checkpoint {
        let title: String
        let subtitle: String?
    }

    private static let checkpoints: [Checkpoint] = [
        Checkpoint(title: "Report submitted", subtitle: "In progress · We’re on it"),
        Checkpoint(title: "Evaluating damage", subtitle: nil),
        Checkpoint(title: "Verifying information", subtitle: nil),
        Checkpoint(title: "Outcome", subtitle: nil)
    ]
}

// MARK: - 10.4 / 10.5 · Damage tracker · evaluating / verifying

private struct ProgressTrackerScreen: View {
    /// 1 = evaluating (10.4), 2 = verifying (10.5).
    var stage: Int
    var back: () -> Void
    var next: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if stage >= 2 {
                TwoLineAppBar(
                    title: "Damage report",
                    subtitle: "Garment Steamer · BR-20481",
                    back: back
                )
            } else {
                BAppBar(
                    title: "Damage report",
                    subtitle: "Garment Steamer · BR-20481",
                    backAction: back
                )
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DNotice(title: noticeTitle, message: noticeBody)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: next)

                    DCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your report’s progress")
                                .font(BFont.bold(17))
                                .foregroundStyle(BColor.ink)
                            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                                HStack(spacing: 14) {
                                    CheckpointMarker(
                                        number: index + 1,
                                        complete: row.complete,
                                        current: row.current
                                    )
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(row.title)
                                            .font(BFont.bold(15))
                                            .foregroundStyle(row.current || row.complete ? BColor.ink : BColor.inkSecondary)
                                        Text(row.subtitle)
                                            .font(BFont.regular(12))
                                            .foregroundStyle(row.current ? BColor.brand : BColor.inkSecondary)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .frame(height: 60)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture(perform: next)

                    DNotice(
                        title: "Next update expected by 21 Oct",
                        message: "We’ll notify you when the next checkpoint is complete. No repair balance is charged without separate consent."
                    )
                    .contentShape(Rectangle())
                    .onTapGesture(perform: next)

                    Text("Submitted 19 Oct 2026 · $10 deposit held during assessment")
                        .font(BFont.regular(12))
                        .foregroundStyle(BColor.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: next) {
                Text("Chat with Thomas")
            }
            .buttonStyle(DButtonStyle())
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }

    private var noticeTitle: String {
        stage >= 2 ? "Verifying information" : "Evaluating damage"
    }

    private var noticeBody: String {
        stage >= 2
            ? "We are checking the handover records and repair information with both members."
            : "Our team is reviewing the damage and comparing the condition photos."
    }

    private struct Row {
        let title: String
        let subtitle: String
        let complete: Bool
        let current: Bool
    }

    private var rows: [Row] {
        let titles = ["Report submitted", "Evaluating damage", "Verifying information", "Outcome"]
        let checkpoint = stage + 1
        return titles.enumerated().map { index, title in
            let complete = index + 1 < checkpoint
            let current = index + 1 == checkpoint
            let subtitle: String
            if complete { subtitle = "Complete" }
            else if current { subtitle = "In progress · Current checkpoint" }
            else { subtitle = "Not started" }
            return Row(title: title, subtitle: subtitle, complete: complete, current: current)
        }
    }
}

// MARK: - 10.6 · Timeline · damage

private struct TimelineDamageScreen: View {
    var back: () -> Void
    var onTrack: () -> Void
    var onReady: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Timeline",
                subtitle: "Garment Steamer · BR-20481",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    TimelineSegments(activeCount: 3)

                    HStack(spacing: 10) {
                        Text("Garment Steamer")
                            .font(BFont.bold(21))
                            .foregroundStyle(BColor.ink)
                        Spacer(minLength: 0)
                        DChip(text: "Lending", fg: BColor.brand, bg: DColor.lendingTag)
                    }
                    .frame(maxWidth: .infinity)

                    DNotice(
                        title: "Damage report in progress",
                        message: "Report submitted ✓ · Evaluating damage · Next update by 21 Oct",
                        fill: DColor.warningSoft
                    )

                    Text("Condition Before → After")
                        .font(BFont.bold(16))
                        .foregroundStyle(BColor.ink)

                    HStack(spacing: 10) {
                        BImageView(photo: .projectorDark, cornerRadius: 10)
                            .frame(height: 85)
                            .frame(maxWidth: .infinity)
                        BImageView(photo: .projectorDark, cornerRadius: 10)
                            .frame(height: 85)
                            .frame(maxWidth: .infinity)
                    }
                    Text("Before · Working and in mint condition · 18 Oct")
                        .font(BFont.regular(12))
                        .foregroundStyle(BColor.inkSecondary)

                    HStack(spacing: 10) {
                        BImageView(photo: BPhoto(key: "photo_bab946ba63"), cornerRadius: 10)
                            .frame(height: 85)
                            .frame(maxWidth: .infinity)
                        BImageView(photo: BPhoto(key: "photo_bab946ba63"), cornerRadius: 10)
                            .frame(height: 85)
                            .frame(maxWidth: .infinity)
                    }
                    Text("After · Dent on steamer body · 19 Oct")
                        .font(BFont.regular(12))
                        .foregroundStyle(BColor.inkSecondary)

                    Button(action: onTrack) {
                        Text("Track damage report")
                    }
                    .buttonStyle(DButtonStyle(kind: .outline))

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(BColor.brand)
                        Text("Deposit · $10 · Held safely")
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.ink)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(DColor.greenSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: onReady) {
                Text("Ready to Return")
            }
            .buttonStyle(DButtonStyle())
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }
}

// MARK: - 10.7 · Timeline · repair

private struct TimelineRepairScreen: View {
    var back: () -> Void
    var onOutcome: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Timeline",
                subtitle: "Garment Steamer · BR-20481",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    RepairProgressBar()

                    DCard(padding: 10) {
                        HStack(spacing: 12) {
                            BImageView(photo: .steamer, cornerRadius: 10)
                                .frame(width: 78, height: 68)
                            Text("Garment Steamer\nCompleted")
                                .font(BFont.bold(18))
                                .foregroundStyle(BColor.ink)
                                .lineSpacing(0)
                            Spacer(minLength: 0)
                        }
                    }

                    HStack(spacing: 10) {
                        BAvatarView(photo: .thomas, size: 38)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text("Thomas")
                                    .font(BFont.bold(15))
                                    .foregroundStyle(BColor.ink)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(BColor.brand)
                            }
                            Text("★ 4.7 · 47 reviews")
                                .font(BFont.bold(15))
                                .foregroundStyle(BColor.ink)
                        }
                        Spacer(minLength: 0)
                        Text("View profile")
                            .font(BFont.bold(11))
                            .foregroundStyle(BColor.brand)
                    }
                    .frame(maxWidth: .infinity)

                    DCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Pickup  ·  18 Oct · 7:30 pm")
                                .frame(height: 24, alignment: .leading)
                            Text("Return  ·  19 Oct · 11:00 pm")
                                .frame(height: 24, alignment: .leading)
                            HStack(spacing: 4) {
                                Image(systemName: "scope")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(BColor.ink)
                                Text("Block A Security Desk")
                            }
                            .frame(height: 24, alignment: .leading)
                        }
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.ink)
                    }

                    Button(action: {}) {
                        Text("View Agreement")
                    }
                    .buttonStyle(DButtonStyle(kind: .outline, font: BFont.bold(14)))

                    Button(action: {}) {
                        Text("Before / After · View condition photos")
                    }
                    .buttonStyle(DButtonStyle(kind: .outline, font: BFont.bold(14)))

                    Text("Deposit Status · Used for repair")
                        .font(BFont.bold(14))
                        .foregroundStyle(BColor.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(DColor.greenSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Button(action: onOutcome) {
                        Text("View damage outcome →")
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.brand)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Button(action: {}) {
                    Text("Chat with Thomas")
                }
                .buttonStyle(DButtonStyle(font: BFont.bold(14)))
                .frame(width: 223)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }
}

// MARK: - 10.8 · Post-Borro review · damage

private struct PostBorroReviewScreen: View {
    var back: () -> Void
    var onPay: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Post-Borro Review",
                subtitle: "Garment Steamer · Damage case",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DNotice(
                        title: "Outcome ✓",
                        message: "Accidental – both parties agree on compensation."
                    )

                    DCard(padding: 10) {
                        HStack(spacing: 10) {
                            BImageView(photo: .damageReview2, cornerRadius: 10)
                                .frame(width: 90, height: 90)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Before")
                                    .font(BFont.bold(15))
                                    .foregroundStyle(BColor.ink)
                                Text("Working and in mint condition")
                                    .font(BFont.regular(13))
                                    .foregroundStyle(BColor.ink)
                                Text("No dents on steamer case")
                                    .font(BFont.regular(12))
                                    .foregroundStyle(BColor.inkSecondary)
                            }
                            Spacer(minLength: 0)
                        }
                    }

                    DCard(padding: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("After · Dent on steamer body")
                                .font(BFont.bold(14))
                                .foregroundStyle(BColor.ink)
                            HStack(spacing: 8) {
                                BImageView(photo: .damageReview3, cornerRadius: 10)
                                    .frame(height: 72)
                                    .frame(maxWidth: .infinity)
                                BImageView(photo: .speakerCyl, cornerRadius: 10)
                                    .frame(height: 72)
                                    .frame(maxWidth: .infinity)
                                ZStack {
                                    BImageView(photo: .speakerCyl, cornerRadius: 10)
                                        .frame(height: 72)
                                        .frame(maxWidth: .infinity)
                                    Circle()
                                        .fill(BColor.ink.opacity(0.67))
                                        .frame(width: 30, height: 30)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            Text("2 photos · 1 video · 0:18")
                                .font(BFont.regular(11))
                                .foregroundStyle(BColor.inkSecondary)
                        }
                    }

                    DCard(padding: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Repair quote")
                                .font(BFont.bold(16))
                                .foregroundStyle(BColor.ink)
                            repairRow("Repair", "$100")
                            repairRow("Deposit applied", "−$50")
                            repairRow("Balance to pay", "$50")
                        }
                    }
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 8) {
                Button(action: onPay) {
                    Text("Pay Now – $50")
                }
                .buttonStyle(DButtonStyle())

                Button(action: {}) {
                    Text("Chat with Thomas")
                }
                .buttonStyle(DButtonStyle(kind: .outline))
            }
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }

    private func repairRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(BFont.regular(14))
                .foregroundStyle(BColor.inkSecondary)
            Spacer(minLength: 0)
            Text(value)
                .font(BFont.semibold(14))
                .foregroundStyle(BColor.ink)
        }
        .frame(height: 26)
    }
}

// MARK: - 10.9 · Repair balance paid

private struct BalancePaidScreen: View {
    var back: () -> Void
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Post-Borro Review",
                subtitle: "Garment Steamer · Damage case",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .stroke(BColor.brand, lineWidth: 3)
                                .frame(width: 56, height: 56)
                            Image(systemName: "checkmark")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(BColor.brand)
                        }
                        .frame(height: 64)

                        Text("All settled.")
                            .font(BFont.bold(29))
                            .foregroundStyle(BColor.ink)
                        Text("Your $50 repair balance is paid.")
                            .font(BFont.regular(16))
                            .foregroundStyle(BColor.ink)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    DNotice(
                        title: "✓ Payment successful – $50 via PayNow",
                        message: "Ref #BR-20481-R · 21 Oct 2026"
                    )

                    DNotice(
                        title: "Outcome ✓ · Case closed",
                        message: "Accidental – both parties agree on compensation."
                    )
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: onDone) {
                Text("View completed borrowing")
            }
            .buttonStyle(DButtonStyle())
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }
}

// MARK: - 10.10 · James · Push · borrowing cancelled

private struct BorrowingCancelledPush: View {
    var onOpen: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            BImageView(photo: .lockScreen, contentMode: .fill, cornerRadius: 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Color.black.opacity(0.08)

            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: "lock")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(height: 24)

                Text("Sunday, 18 October")
                    .font(BFont.regular(19))
                    .foregroundStyle(.white)
                    .frame(height: 26, alignment: .leading)

                Text("10:00")
                    .font(BFont.bold(76))
                    .foregroundStyle(.white)
                    .frame(height: 100, alignment: .leading)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        BorroAppIcon()
                        Text("BORRO")
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.ink)
                        Spacer(minLength: 0)
                        Text("now")
                            .font(BFont.regular(11))
                            .foregroundStyle(BColor.inkSecondary)
                    }
                    Text("Your borrowing was cancelled")
                        .font(BFont.bold(16))
                        .foregroundStyle(BColor.ink)
                    Text("Thomas cancelled your steamer borrowing. Your $10 deposit will be returned within 1 working day.")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("3 nearby alternatives are ready for you.")
                        .font(BFont.bold(13))
                        .foregroundStyle(BColor.brand)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.93))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(.white.opacity(0.4), lineWidth: 1)
                }

                Text("Cancellation details in My Borrowing")
                    .font(BFont.regular(12))
                    .foregroundStyle(.white)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.top, 76)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .ignoresSafeArea()
    }
}

// MARK: - 10.11 · Borrowing cancelled · alternatives

private struct CancelledAlternativesScreen: View {
    var back: () -> Void
    var onSeeAlternatives: () -> Void
    var onRequest: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Borrowing cancelled",
                subtitle: "My Borrowing · Thomas",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Here are 3 nearby alternatives")
                        .font(BFont.bold(21))
                        .foregroundStyle(BColor.ink)
                    Text("Keep your movie night on. We found lenders who can help tonight.")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    AlternativeLenderCard(
                        name: "Thomas",
                        avatar: .alt1,
                        credibility: "Credibility 91/100 · High",
                        distance: "350 m",
                        onRequest: onRequest
                    )

                    DNotice(
                        title: "Sorry, your borrowing was cancelled.",
                        message: "Thomas cancelled: unavailable due to personal circumstances.",
                        fill: DColor.redSoft,
                        titleColor: DColor.redInk
                    )

                    DCard {
                        HStack(spacing: 12) {
                            BImageView(photo: .damageReview2, cornerRadius: 10)
                                .frame(width: 90, height: 90)
                            VStack(alignment: .leading, spacing: 7) {
                                Text("Garment Steamer")
                                    .font(BFont.bold(16))
                                    .foregroundStyle(BColor.ink)
                                Text("Thomas · Blk 67 lobby")
                                    .font(BFont.regular(13))
                                    .foregroundStyle(BColor.ink)
                                DChip(text: "Cancelled")
                            }
                            Spacer(minLength: 0)
                        }
                    }

                    DNotice(
                        title: "Your deposit is on its way back",
                        message: "Your $10 deposit will be returned within 1 working day."
                    )
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: onSeeAlternatives) {
                Text("See 3 nearby alternatives")
            }
            .buttonStyle(DButtonStyle())
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }
}

// MARK: - 10.12 · Nearby alternatives

private struct NearbyAlternativesScreen: View {
    var back: () -> Void
    var onFindLender: () -> Void
    var onRequest: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Nearby alternatives",
                subtitle: "Garment Steamer · 18–19 Oct",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Here are 3 nearby alternatives. No need to start over.")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.inkSecondary)

                    AlternativeLenderCard(
                        name: "Leon",
                        avatar: .alt3,
                        credibility: "Credibility 89/100 · High",
                        distance: "564 m",
                        onRequest: onRequest
                    )
                    AlternativeLenderCard(
                        name: "Mei Lin",
                        avatar: .alt3,
                        credibility: "Credibility 87/100 · High",
                        distance: "200 m",
                        onRequest: onRequest
                    )
                    AlternativeLenderCard(
                        name: "Thomas",
                        avatar: .alt1,
                        credibility: "Credibility 91/100 · High",
                        distance: "350 m",
                        onRequest: onRequest
                    )
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: onFindLender) {
                Text("Find a New Lender")
            }
            .buttonStyle(DButtonStyle())
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
        }
    }
}

// MARK: - 10.13 · Find new lender

private struct FindNewLenderScreen: View {
    var back: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Find new lender",
                subtitle: "My Borrowing · Steamer replacement",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    DNotice(
                        title: "Thomas cancelled",
                        message: "Unavailable due to personal circumstances."
                    )

                    HStack(spacing: 6) {
                        Image(systemName: "scope")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(BColor.ink)
                        Text("Recommended for your dates")
                            .font(BFont.bold(17))
                            .foregroundStyle(BColor.ink)
                    }

                    VStack(spacing: 14) {
                        PinnedLenderCard(
                            name: "Thomas", distance: "564 m", score: "86",
                            avatar: .thomas, photo: .projector
                        )
                        PinnedLenderCard(
                            name: "Matthew", distance: "200 m", score: "86",
                            avatar: .lebron, photo: .projector
                        )
                        PinnedLenderCard(
                            name: "Jessica", distance: "350 m", score: "86",
                            avatar: .lebron, photo: .projector
                        )
                    }

                    Button(action: {}) {
                        Text("Search for other")
                    }
                    .buttonStyle(DButtonStyle(height: 46, font: BFont.bold(14)))

                    Text("New results nearby")
                        .font(BFont.bold(16))
                        .foregroundStyle(BColor.ink)

                    DCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Portable steamer · Daniel")
                                .font(BFont.bold(14))
                                .foregroundStyle(BColor.ink)
                            Text("780 m · Available 18–19 Oct 2026")
                                .font(BFont.regular(12))
                                .foregroundStyle(BColor.inkSecondary)
                        }
                    }
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - Shared section-10 components

private struct DNotice: View {
    var title: String
    var message: String? = nil
    var fill: Color = DColor.greenSoft
    var titleColor: Color = BColor.ink

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(BFont.bold(14))
                .foregroundStyle(titleColor)
            if let message {
                Text(message)
                    .font(BFont.regular(13))
                    .foregroundStyle(BColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(fill)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct DCard<Content: View>: View {
    var padding: CGFloat = 12
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(BColor.stroke, lineWidth: 0.7)
            }
            .bShadow(1)
    }
}

private struct DButtonStyle: ButtonStyle {
    enum Kind { case primary, outline, disabled }

    var kind: Kind = .primary
    var height: CGFloat = 48
    var font: Font = BFont.bold(15)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(kind == .outline ? BColor.brand : .clear, lineWidth: 1.2)
            }
            .opacity(configuration.isPressed ? 0.9 : 1)
    }

    private var foreground: Color {
        switch kind {
        case .primary: return .white
        case .outline: return BColor.brand
        case .disabled: return BColor.inkSecondary
        }
    }

    private var background: Color {
        switch kind {
        case .primary: return BColor.brand
        case .outline: return BColor.surface
        case .disabled: return DColor.disabledFill
        }
    }
}

private struct DChip: View {
    var text: String
    var fg: Color = BColor.inkSecondary
    var bg: Color = DColor.chipFill

    var body: some View {
        Text(text)
            .font(BFont.bold(11))
            .foregroundStyle(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bg)
            .clipShape(Capsule())
    }
}

private struct SelectableChip: View {
    var text: String
    var isOn: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(BFont.bold(11))
                .foregroundStyle(isOn ? DColor.greenInk : BColor.inkSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isOn ? DColor.greenSoft : DColor.chipFill)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct AngleTile: View {
    var photo: BPhoto
    var label: String

    var body: some View {
        VStack(spacing: 4) {
            BImageView(photo: photo, cornerRadius: 10)
                .frame(height: 65)
                .frame(maxWidth: .infinity)
            HStack(spacing: 4) {
                Text(label)
                    .font(BFont.bold(11))
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(BColor.ink)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DamageDescriptionField: View {
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("Describe what happened…")
                    .font(BFont.regular(15))
                    .foregroundStyle(BColor.inkSecondary)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 13)
            }
            TextField("", text: $text, axis: .vertical)
                .font(BFont.regular(15))
                .foregroundStyle(BColor.ink)
                .lineLimit(3...8)
                .padding(.horizontal, 13)
                .padding(.vertical, 13)
        }
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .topLeading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 1)
        }
    }
}

private struct TwoLineAppBar: View {
    var title: String
    var subtitle: String
    var back: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: back) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)

            Text("\(title)\n\(subtitle)")
                .font(BFont.bold(21))
                .foregroundStyle(BColor.ink)
                .lineSpacing(0)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, BSpace.screen)
        .frame(height: BMetric.appBarHeight)
        .background(BColor.bg)
    }
}

private struct CheckpointMarker: View {
    var number: Int
    var complete: Bool
    var current: Bool

    var body: some View {
        ZStack {
            if complete {
                Circle().fill(DColor.greenSoft)
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(BColor.brand)
            } else if current {
                Circle().fill(BColor.brand)
                Text("\(number)")
                    .font(BFont.bold(15))
                    .foregroundStyle(.white)
            } else {
                Circle().fill(DColor.chipFill)
                Text("\(number)")
                    .font(BFont.bold(15))
                    .foregroundStyle(BColor.inkSecondary)
            }
        }
        .frame(width: 36, height: 36)
    }
}

private struct TimelineSegments: View {
    var activeCount: Int
    private let labels = ["Agreed", "Meet-up", "Lending", "Return"]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                VStack(spacing: 5) {
                    Capsule()
                        .fill(index < activeCount ? BColor.brand : BColor.stroke)
                        .frame(height: 4)
                    Text(label)
                        .font(BFont.semibold(10))
                        .foregroundStyle(BColor.inkSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct RepairProgressBar: View {
    private let labels = ["Agreed", "Meet-up", "Lending", "Return"]

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Capsule()
                .fill(BColor.stroke)
                .frame(height: 4)
            HStack(spacing: 0) {
                ForEach(labels, id: \.self) { label in
                    Text(label)
                        .font(BFont.regular(10))
                        .foregroundStyle(BColor.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

private struct AlternativeLenderCard: View {
    var name: String
    var avatar: BPhoto
    var credibility: String
    var distance: String
    var onRequest: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                BAvatarView(photo: avatar, size: 32)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(name)
                            .font(BFont.bold(14))
                            .foregroundStyle(BColor.ink)
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(BColor.brand)
                    }
                    Text(credibility)
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                }
                Spacer(minLength: 0)
                DChip(text: distance, fg: DColor.greenInk, bg: DColor.greenSoft)
            }

            HStack(spacing: 12) {
                BImageView(photo: .alt2, cornerRadius: 10)
                    .frame(width: 95, height: 80)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Garment Steamer")
                        .font(BFont.bold(14))
                        .foregroundStyle(BColor.ink)
                    Text("★ 4.9 · Available 18–19 Oct")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                    Button(action: onRequest) {
                        Text("Request")
                    }
                    .buttonStyle(DButtonStyle(kind: .outline))
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow(1)
    }
}

private struct PinnedLenderCard: View {
    var name: String
    var distance: String
    var score: String
    var avatar: BPhoto
    var photo: BPhoto

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                BAvatarView(photo: avatar, size: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(name) · \(distance)")
                        .font(BFont.bold(14))
                        .foregroundStyle(BColor.ink)
                    Text("\(score)/100 · High")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.brand)
                }
                Spacer(minLength: 0)
                HStack(spacing: 2) {
                    Image(systemName: "scope")
                        .font(.system(size: 9, weight: .medium))
                    Text("Pinned")
                        .font(BFont.regular(10))
                }
                .foregroundStyle(BColor.brand)
            }

            HStack(spacing: 12) {
                BImageView(photo: photo, cornerRadius: 10)
                    .frame(width: 70, height: 57)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Garment Steamer")
                        .font(BFont.bold(12))
                        .foregroundStyle(BColor.ink)
                    Text("18–19 Oct · $10 deposit")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                }
                Spacer(minLength: 0)
                Button(action: {}) {
                    Text("Request")
                }
                .buttonStyle(DButtonStyle(height: 48, font: BFont.bold(14)))
                .frame(width: 84)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow(1)
    }
}

/// The blue Borro app mark shown inside the cancelled-borrowing push mock.
private struct BorroAppIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(BColor.brand, style: StrokeStyle(lineWidth: 2.6, lineCap: .round))
                .rotationEffect(.degrees(40))
                .frame(width: 21, height: 21)
            Circle()
                .fill(BColor.brand)
                .frame(width: 5, height: 5)
                .offset(x: 6, y: 5)
        }
        .frame(width: 28, height: 28)
    }
}
