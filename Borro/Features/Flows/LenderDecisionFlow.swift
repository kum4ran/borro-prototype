import SwiftUI

// Lender decides — Figma section 3 · Lender decides (Thomas)
//
//   691-5139  3.1 Thomas · Push · new request          (lock-screen mock)
//   700-125   3.2 Thomas · Borrow Requests
//   700-198   3.3 Thomas · Borrow request expanded
//   691-5216  3.4 Thomas · James public profile
//   701-124   3.5 Thomas · Credibility score info      (tooltip over profile)
//   691-5308  3.6 Thomas · James all reviews
//   700-439   3.7 Thomas · Accept James' request?      (dialog over 3.2)
//   700-520   3.8 James · Push · request accepted      (lock-screen mock)
//   691-5405  3.9 James · Request accepted
//
// Same slug-stack state machine as RequestFlow so every artboard can be
// deep-linked through `startScreen`.

// MARK: - Request fixtures shown on 3.2 / 3.3

private struct LenderRequestRow: Identifiable {
    let id: String
    let name: String
    let score: String
    let scoreLine: String
    let identity: String
    let dates: String
    let urgent: Bool
    let photo: BPhoto
}

private let lenderRequests: [LenderRequestRow] = [
    LenderRequestRow(
        id: "james", name: "James",
        score: "72/100 · Moderate",
        scoreLine: "72/100 · Moderate  ★ 3.5 (45 reviews)",
        identity: "21 · Singapore Halls · Identity verified ✓",
        dates: "18–19 Oct 2026", urgent: true, photo: .james
    ),
    LenderRequestRow(
        id: "mei", name: "Mei",
        score: "86/100 · High",
        scoreLine: "86/100 · High  ★ 4.7 (18 reviews)",
        identity: "27 · Bencoolen · Identity verified ✓",
        dates: "20–21 Oct 2026", urgent: true, photo: BPhoto(key: "avatar_woman4")
    ),
    LenderRequestRow(
        id: "darren", name: "Darren",
        score: "86/100 · High",
        scoreLine: "86/100 · High  ★ 4.7 (18 reviews)",
        identity: "31 · Bencoolen · Identity verified ✓",
        dates: "20–21 Oct 2026", urgent: false, photo: BPhoto(key: "avatar_man1")
    )
]

// MARK: - State machine

struct LenderDecisionFlow: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: BorroStore

    var startScreen: String? = nil

    @State private var stack: [String] = []
    @State private var showAcceptDialog = false
    @State private var acceptingName = "James"
    @State private var expandedID = "james"
    @State private var rejectedIDs: Set<String> = []
    @State private var showCredibilityInfo = false
    @State private var didApplyStart = false

    private let entryScreen = "700-125"
    private var current: String { stack.last ?? entryScreen }
    private var isLockScreen: Bool { current == "691-5139" || current == "700-520" }
    private var tabSelection: AppTab { current == "691-5405" ? .borro : .lend }

    var body: some View {
        content
            .bBackground()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isLockScreen {
                    RQTabBar(selected: tabSelection)
                }
            }
            .overlay { acceptDialogLayer }
            .onAppear(perform: applyStartScreen)
    }

    // MARK: Screens

    @ViewBuilder
    private var content: some View {
        switch current {
        case "691-5139":
            BPushScreen(
                title: "James wants to borrow your Garment Steamer",
                message: "Borrow Now (urgent) · 18–19 Oct. Tap to review his profile and respond.",
                onOpen: { openFromLock("700-125") }
            )

        case "700-198":
            LenderRequestsView(
                expandedID: expandedID,
                rejectedIDs: rejectedIDs,
                onBack: back,
                onAccept: accept,
                onReject: reject,
                onExpand: expand,
                onProfile: { go("691-5216") },
                onChat: openChat,
                onInfo: { go("701-124") }
            )

        case "691-5216":
            LenderPublicProfileView(
                variant: .full,
                showTooltip: false,
                onBack: back,
                onChat: openChat,
                onInfo: { openCredibilityInfo() },
                onSeeReviews: { go("691-5308") },
                onDismissTip: {},
                onStandardInfo: {}
            )

        case "701-124":
            LenderPublicProfileView(
                variant: .info,
                showTooltip: showCredibilityInfo,
                onBack: dismissCredibilityInfo,
                onChat: openChat,
                onInfo: dismissCredibilityInfo,
                onSeeReviews: nil,
                onDismissTip: dismissCredibilityInfo,
                onStandardInfo: dismissCredibilityInfo
            )

        case "691-5308":
            LenderAllReviewsView(onBack: back)

        case "691-5405":
            LenderRequestAcceptedView(
                item: store.activeItem,
                onBack: back,
                onArrangeHandover: { router.push(.flow(.schedule, screen: "701-203")) },
                onMyBorrowing: { router.switchTab(.borro) }
            )

        case "700-520":
            BPushScreen(
                title: "Thomas accepted your request",
                message: "Garment Steamer · 18–19 Oct. Tap to arrange pick-up and meeting spot.",
                onOpen: { openFromLock("691-5405") }
            )

        default:
            LenderRequestsView(
                expandedID: nil,
                rejectedIDs: rejectedIDs,
                onBack: back,
                onAccept: accept,
                onReject: reject,
                onExpand: expand,
                onProfile: { go("691-5216") },
                onChat: openChat,
                onInfo: { go("701-124") }
            )
        }
    }

    // MARK: 3.7 accept dialog

    @ViewBuilder
    private var acceptDialogLayer: some View {
        if showAcceptDialog {
            ZStack {
                RQPalette.scrimInk.opacity(0.33)
                    .ignoresSafeArea()
                    .onTapGesture { showAcceptDialog = false }

                VStack(alignment: .leading, spacing: 18) {
                    Text("Accept \(acceptingName)’s request?")
                        .font(BFont.bold(23))
                        .foregroundStyle(BColor.ink)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Accept \(acceptingName)’s request for 18–19 Oct?")
                            .font(BFont.bold(16))
                            .foregroundStyle(BColor.inkSecondary)
                        Text("You’ll arrange the pickup together after confirming.")
                            .font(BFont.regular(16))
                            .foregroundStyle(BColor.inkSecondary)
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 18) {
                        Button {
                            confirmAccept()
                        } label: {
                            Text("Confirm")
                                .font(BFont.bold(15))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(BColor.brand)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        Button {
                            showAcceptDialog = false
                        } label: {
                            Text("Cancel")
                                .font(BFont.bold(15))
                                .foregroundStyle(BColor.brand)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(BColor.surface)
                                .clipShape(Capsule())
                                .overlay { Capsule().stroke(BColor.brand, lineWidth: 1.2) }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(22)
                .frame(width: 345)
                .background(BColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .bShadow(3)
            }
            .transition(.opacity)
        }
    }

    // MARK: Actions

    private func accept(_ row: LenderRequestRow) {
        acceptingName = row.name
        showAcceptDialog = true
    }

    private func reject(_ row: LenderRequestRow) {
        rejectedIDs.insert(row.id)
        if current == "700-198" { back() }
    }

    private func expand(_ row: LenderRequestRow) {
        expandedID = row.id
        go("700-198")
    }

    private func confirmAccept() {
        showAcceptDialog = false
        store.request.status = .accepted
        go("700-520")
    }

    private func openChat() {
        router.push(.flow(.schedule, screen: "691-5576"))
    }

    private func openCredibilityInfo() {
        withAnimation(.easeOut(duration: 0.15)) { showCredibilityInfo = true }
        go("701-124")
    }

    private func dismissCredibilityInfo() {
        withAnimation(.easeOut(duration: 0.15)) { showCredibilityInfo = false }
        back()
    }

    // MARK: Navigation

    private func go(_ slug: String) {
        withAnimation(.easeOut(duration: 0.2)) { stack.append(slug) }
    }

    private func openFromLock(_ slug: String) {
        withAnimation(.easeOut(duration: 0.2)) { stack = [slug] }
    }

    private func back() {
        if stack.count > 1 {
            withAnimation(.easeOut(duration: 0.2)) { stack.removeLast() }
        } else {
            router.pop()
        }
    }

    private func applyStartScreen() {
        guard !didApplyStart else { return }
        didApplyStart = true
        guard let slug = startScreen else {
            stack = [entryScreen]
            return
        }
        switch slug {
        case "691-5139":
            stack = ["691-5139"]
        case "700-198":
            stack = ["700-198"]
            expandedID = "james"
        case "691-5216":
            stack = ["691-5216"]
        case "691-5308":
            stack = ["691-5308"]
        case "700-439":
            stack = ["700-125"]
            acceptingName = "James"
            DispatchQueue.main.async { showAcceptDialog = true }
        case "700-520":
            stack = ["700-520"]
        case "691-5405":
            stack = ["691-5405"]
        case "701-124":
            stack = ["691-5216", "701-124"]
            showCredibilityInfo = true
        default:
            stack = [entryScreen]
        }
    }
}

// MARK: - 3.2 / 3.3 · Borrow Requests

private struct LenderRequestsView: View {
    var expandedID: String?
    var rejectedIDs: Set<String>
    var onBack: () -> Void
    var onAccept: (LenderRequestRow) -> Void
    var onReject: (LenderRequestRow) -> Void
    var onExpand: (LenderRequestRow) -> Void
    var onProfile: () -> Void
    var onChat: () -> Void
    var onInfo: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Borrow Requests",
                subtitle: "Thomas · 3 new requests",
                backAction: onBack
            )

            ScrollView {
                VStack(spacing: 12) {
                    if let id = expandedID,
                       let row = lenderRequests.first(where: { $0.id == id }) {
                        expandedCard(row)
                    } else {
                        ForEach(lenderRequests.filter { !rejectedIDs.contains($0.id) }) { row in
                            collapsedCard(row)
                        }
                    }
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, BSpace.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: 3.2

    private func collapsedCard(_ row: LenderRequestRow) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                memberRow(row, score: row.score, scoreSize: 13, showsInfo: false)
                Text("\(row.name) wants to borrow Garment Steamer")
                    .font(BFont.regular(15))
                    .foregroundStyle(BColor.ink)
                Text(row.dates)
                    .font(BFont.regular(13))
                    .foregroundStyle(BColor.inkSecondary)
                if row.urgent {
                    RQStatusChip(text: "⚡ URGENT – Borrow Now")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { onExpand(row) }

            HStack(spacing: 16) {
                acceptButton(row, size: 14)
                rejectButton(row, size: 14)
            }
        }
        .rqCard()
    }

    // MARK: 3.3

    private func expandedCard(_ row: LenderRequestRow) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            memberRow(row, score: row.scoreLine, scoreSize: 11, showsInfo: true)
            Text(row.identity)
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)

            HStack(spacing: 12) {
                // Figma fills the expanded request item photo with steamer_shirt3.
                BImageView(photo: .steamerShirt, cornerRadius: BRadius.photo)
                    .frame(width: 70, height: 70)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Garment Steamer")
                        .font(BFont.bold(16))
                        .foregroundStyle(BColor.ink)
                    Text(row.dates)
                        .font(BFont.regular(13))
                        .foregroundStyle(BColor.ink)
                    if row.urgent {
                        RQStatusChip(text: "⚡ URGENT – Borrow Now")
                    }
                }
                Spacer(minLength: 0)
            }

            RQMonthCalendar(weekStart: .sunday, selected: [18, 19])

            HStack(spacing: 16) {
                acceptButton(row, size: 15)
                rejectButton(row, size: 15)
            }

            HStack(spacing: 12) {
                Button(action: onChat) { outlineLabel("Chat") }
                    .buttonStyle(.plain)
                Button(action: onProfile) { outlineLabel("View full profile") }
                    .buttonStyle(.plain)
            }
        }
        .rqCard()
    }

    // MARK: Pieces

    private func memberRow(_ row: LenderRequestRow, score: String,
                           scoreSize: CGFloat, showsInfo: Bool) -> some View {
        HStack(spacing: 10) {
            BAvatarView(
                photo: row.photo,
                initials: String(row.name.prefix(1)).uppercased(),
                size: 38
            )
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(row.name)
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(BColor.brand)
                }
                Text(score)
                    .font(BFont.regular(scoreSize))
                    .foregroundStyle(BColor.inkSecondary)
            }
            Spacer(minLength: 0)
            if showsInfo {
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(BColor.brand)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func acceptButton(_ row: LenderRequestRow, size: CGFloat) -> some View {
        Button { onAccept(row) } label: {
            Text("Accept")
                .font(BFont.bold(size))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(BColor.brand)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func rejectButton(_ row: LenderRequestRow, size: CGFloat) -> some View {
        Button { onReject(row) } label: {
            Text("Reject")
                .font(BFont.bold(size))
                .foregroundStyle(RQPalette.reject)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(BColor.surface)
                .clipShape(Capsule())
                .overlay { Capsule().stroke(RQPalette.reject, lineWidth: 1.2) }
        }
        .buttonStyle(.plain)
    }

    private func outlineLabel(_ text: String) -> some View {
        Text(text)
            .font(BFont.bold(15))
            .foregroundStyle(BColor.brand)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(BColor.surface)
            .clipShape(Capsule())
            .overlay { Capsule().stroke(BColor.brand, lineWidth: 1.2) }
    }
}

// MARK: - Credibility data

private struct CredibilityDimension: Identifiable {
    var id: String { label }
    let label: String
    let value: Int
    /// Explicit bar fraction when the Figma bar width is not value/100 (3.5).
    let fraction: Double?
}

private let credibilityFull: [CredibilityDimension] = [
    CredibilityDimension(label: "Successful transactions", value: 80, fraction: nil),
    CredibilityDimension(label: "On-time returns", value: 65, fraction: nil),
    CredibilityDimension(label: "Item condition after return", value: 78, fraction: nil),
    CredibilityDimension(label: "Communication", value: 60, fraction: nil),
    CredibilityDimension(label: "Cancellation rate", value: 85, fraction: nil),
    CredibilityDimension(label: "Reviews", value: 64, fraction: nil)
]

private let credibilityWithIdentity: [CredibilityDimension] = [
    CredibilityDimension(label: "Successful transactions", value: 80, fraction: 80.0 / 136.0),
    CredibilityDimension(label: "On-time returns", value: 65, fraction: 65.0 / 136.0),
    CredibilityDimension(label: "Item condition after return", value: 78, fraction: 85.0 / 136.0),
    CredibilityDimension(label: "Communication", value: 60, fraction: 70.0 / 136.0),
    CredibilityDimension(label: "Identity verified ✓", value: 100, fraction: 100.0 / 136.0),
    CredibilityDimension(label: "Cancellation rate", value: 85, fraction: 90.0 / 136.0),
    CredibilityDimension(label: "Reviews", value: 64, fraction: 70.0 / 136.0)
]

private struct CredibilityRow: View {
    var dimension: CredibilityDimension
    var showsValue: Bool

    private var fraction: Double {
        dimension.fraction ?? min(1, max(0, Double(dimension.value) / 100.0))
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(dimension.label)
                .font(BFont.regular(11))
                .foregroundStyle(BColor.inkSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack(alignment: .leading) {
                Capsule().fill(RQPalette.busyFill).frame(width: 138, height: 5)
                Capsule().fill(BColor.brand).frame(width: 138 * fraction, height: 5)
            }
            .frame(width: 138, height: 5)

            if showsValue {
                Text("\(dimension.value)")
                    .font(BFont.bold(11))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 34, alignment: .trailing)
            }
        }
        .frame(height: 13)
    }
}

/// Semi-circular credibility gauge (Figma: 170x85 ellipse, 13pt stroke).
private struct CredibilityGauge: View {
    var score: Double = 72
    var title: String
    var titleSize: CGFloat = 25
    var caption: String?
    var onInfo: (() -> Void)?

    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                Ellipse()
                    .trim(from: 0.5, to: 1.0)
                    .stroke(BColor.stroke, style: StrokeStyle(lineWidth: 13, lineCap: .butt))
                Ellipse()
                    .trim(from: 0.5, to: 0.5 + 0.5 * min(1, max(0, score / 100)))
                    .stroke(BColor.brand, style: StrokeStyle(lineWidth: 13, lineCap: .butt))
            }
            .frame(width: 170, height: 85)

            VStack(spacing: 2) {
                Text(title)
                    .font(BFont.bold(titleSize))
                    .foregroundStyle(BColor.ink)
                    .lineLimit(1)
                if let caption {
                    HStack(spacing: 4) {
                        Text(caption)
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.brand)
                        if let onInfo {
                            Button(action: onInfo) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(BColor.brand)
                                    .frame(width: 16, height: 16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.top, 38)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 114, alignment: .top)
    }
}

// MARK: - 3.4 / 3.5 · Public profile

private struct LenderPublicProfileView: View {
    enum Variant { case full, info }

    var variant: Variant
    var showTooltip: Bool
    var onBack: () -> Void
    var onChat: () -> Void
    var onInfo: () -> Void
    var onSeeReviews: (() -> Void)?
    var onDismissTip: () -> Void
    var onStandardInfo: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if variant == .full {
                RQBigAppBar(title: "Public profile", backAction: onBack)
            } else {
                BAppBar(title: "Public profile", backAction: onBack)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    identity
                    chatButton
                    if variant == .full {
                        credibilityCardFull
                    } else {
                        credibilityCardInfo
                    }
                    ratingCard
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, BSpace.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var identity: some View {
        HStack(spacing: 15) {
            BAvatarView(photo: .james, initials: "JT", size: 70)
            VStack(alignment: .leading, spacing: variant == .full ? 5 : 4) {
                Text("James")
                    .font(BFont.bold(23))
                    .foregroundStyle(BColor.ink)
                if variant == .full {
                    Text("21 · Singapore")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.inkSecondary)
                    RQStatusChip(
                        text: "✓ Identity verified",
                        foreground: RQPalette.freeInk,
                        background: RQPalette.freeFill
                    )
                } else {
                    Text("21 · Singapore · West Wing Hall")
                        .font(BFont.regular(13))
                        .foregroundStyle(BColor.inkSecondary)
                    Text("Identity verified ✓")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.brand)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var chatButton: some View {
        Button(action: onChat) {
            Text("Chat Now")
                .font(BFont.bold(variant == .full ? 15 : 14))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(BColor.brand)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: 3.4

    private var credibilityCardFull: some View {
        VStack(alignment: .leading, spacing: 10) {
            CredibilityGauge(
                title: "72/100",
                titleSize: 25,
                caption: "Moderate",
                onInfo: onInfo
            )
            Text("Credibility breakdown")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            ForEach(credibilityFull) { dimension in
                CredibilityRow(dimension: dimension, showsValue: true)
            }
        }
        .rqCard()
    }

    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            if variant == .full {
                HStack {
                    Text("Overall rating")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.inkSecondary)
                    Spacer()
                    Text("★ 3.5 · 45 reviews")
                        .font(BFont.semibold(14))
                        .foregroundStyle(BColor.ink)
                }
                Text("“Returned the item cleaned.”")
                    .font(BFont.regular(13))
                    .foregroundStyle(BColor.ink)
                Text("Kumaran · 12 Oct 2026")
                    .font(BFont.regular(11))
                    .foregroundStyle(BColor.inkSecondary)
                if let onSeeReviews {
                    Button(action: onSeeReviews) {
                        Text("See all reviews →")
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.brand)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("★ 3.5 (45 reviews)")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
                Text("“Friendly and easy to arrange with.”")
                    .font(BFont.regular(13))
                    .foregroundStyle(BColor.ink)
                Text("Thomas · 12 Oct 2026")
                    .font(BFont.regular(11))
                    .foregroundStyle(BColor.inkSecondary)
            }
        }
        .rqCard()
    }

    // MARK: 3.5

    private var credibilityCardInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            CredibilityGauge(
                title: "72/100 · Moderate",
                titleSize: 24,
                caption: "Credibility score",
                onInfo: variant == .info ? onStandardInfo : onInfo
            )
            VStack(alignment: .leading, spacing: 9) {
                Text("Credibility breakdown")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
                ForEach(credibilityWithIdentity) { dimension in
                    CredibilityRow(dimension: dimension, showsValue: false)
                }
            }
        }
        .rqCard()
        .overlay(alignment: .top) {
            if showTooltip {
                CredibilityTooltipCard()
                    .offset(y: 96)
                    .onTapGesture(perform: onDismissTip)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }
}

// MARK: - 3.5 tooltip

private struct CredibilityTooltipCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How credibility is calculated")
                .font(BFont.bold(16))
                .foregroundStyle(Color.white)
            Text("Your score reflects successful transactions, on-time returns, item condition, communication, identity verification and cancellation history.")
                .font(BFont.regular(14))
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
            Text("Stars are reviewers’ average rating — not the same as your credibility score.")
                .font(BFont.regular(14))
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
            Text("72/100 · Moderate")
                .font(BFont.bold(13))
                .foregroundStyle(RQPalette.tooltipGreen)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RQPalette.scrimInk)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .bShadow(2)
    }
}

// MARK: - 3.6 · James' Reviews

private struct LenderAllReviewsView: View {
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            RQBigAppBar(title: "James’ Reviews", backAction: onBack)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    identity
                    breakdownCard
                    HStack(alignment: .firstTextBaseline) {
                        Text("Detailed reviews")
                            .font(BFont.bold(18))
                            .foregroundStyle(Color.black)
                        Spacer()
                        Text("★ 3.5 (45 reviews)")
                            .font(BFont.bold(13))
                            .foregroundStyle(Color.black)
                    }
                    reviewCard(
                        author: "Kumaran",
                        stars: 4,
                        text: "Returned the item cleaned.",
                        date: "12 Oct 2026"
                    )
                    reviewCard(
                        author: "Maria",
                        stars: 3,
                        text: "Good communication, but the return was a little late.",
                        date: "8 Oct 2026"
                    )
                    reviewCard(
                        author: "Regen",
                        stars: 4,
                        text: "Careful with my drill. He would lend the item again.",
                        date: "2 Oct 2026"
                    )
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, BSpace.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var identity: some View {
        HStack(spacing: 15) {
            BAvatarView(photo: .james, initials: "JT", size: 70)
            VStack(alignment: .leading, spacing: 5) {
                Text("James")
                    .font(BFont.bold(23))
                    .foregroundStyle(BColor.ink)
                Text("21 · Singapore")
                    .font(BFont.regular(14))
                    .foregroundStyle(BColor.inkSecondary)
                RQStatusChip(
                    text: "✓ Identity verified",
                    foreground: RQPalette.freeInk,
                    background: RQPalette.freeFill
                )
            }
            Spacer(minLength: 0)
        }
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("72/100 · Moderate")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            VStack(alignment: .leading, spacing: 9) {
                Text("Credibility breakdown")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
                ForEach(credibilityFull) { dimension in
                    CredibilityRow(dimension: dimension, showsValue: true)
                }
            }
        }
        .rqCard()
    }

    private func reviewCard(author: String, stars: Int, text: String, date: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(author)
                    .font(BFont.bold(14))
                    .foregroundStyle(Color.black)
                Spacer()
                Text(starString(stars))
                    .font(BFont.regular(15))
                    .foregroundStyle(RQPalette.urgentInk)
            }
            Text(text)
                .font(BFont.regular(13))
                .foregroundStyle(BColor.ink)
            Text(date)
                .font(BFont.regular(11))
                .foregroundStyle(BColor.inkSecondary)
        }
        .rqCard()
    }

    private func starString(_ stars: Int) -> String {
        String(repeating: "★", count: max(0, min(5, stars)))
            + String(repeating: "☆", count: max(0, 5 - min(5, stars)))
    }
}

// MARK: - 3.9 · Request accepted

private struct LenderRequestAcceptedView: View {
    var item: Item
    var onBack: () -> Void
    var onArrangeHandover: () -> Void
    var onMyBorrowing: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Request Accepted",
                subtitle: "Borrow Now · Lender approval",
                backAction: onBack
            )

            ScrollView {
                VStack(spacing: 12) {
                    resultBlock
                    requestCard
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, BSpace.lg)
            }
            .scrollIndicators(.hidden)

            actions
        }
    }

    private var resultBlock: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(RQPalette.freeFill)
                    .frame(width: 76, height: 76)
                Image(systemName: "checkmark")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(BColor.brand)
            }
            Text("Approved by Thomas")
                .font(BFont.bold(24))
                .foregroundStyle(BColor.ink)
            Text("Next, agree on a pickup time and meeting place together.")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 22)
    }

    private var requestCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            BImageView(photo: item.photo, cornerRadius: BRadius.photo)
                .frame(height: 110)
                .frame(maxWidth: .infinity)
            Text(item.title)
                .font(BFont.bold(19))
                .foregroundStyle(BColor.ink)
            RQStatusChip(text: "URGENT - Borrow Now", foreground: .white, background: BColor.brand)
            acceptedDetailRow("Borrower", "James")
            acceptedDetailRow("Lender", "Thomas")
            acceptedDetailRow("Requested dates", "18 → 19 Oct 2026")
            acceptedDetailRow("Duration", "1 day")
        }
        .rqCard()
    }

    private func acceptedDetailRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
            Text("  ·  ")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
            Text(value)
                .font(BFont.regular(13))
                .foregroundStyle(BColor.ink)
            Spacer(minLength: 0)
        }
        .frame(height: 24)
    }

    private var actions: some View {
        VStack(spacing: 8) {
            Button(action: onArrangeHandover) {
                Text("Arrange handover")
                    .font(BFont.bold(14))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(BColor.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button(action: onMyBorrowing) {
                Text("View My Borrowing")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.brand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(BColor.surface)
                    .clipShape(Capsule())
                    .overlay { Capsule().stroke(BColor.brand, lineWidth: 1.2) }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .background(BColor.bg)
    }
}
