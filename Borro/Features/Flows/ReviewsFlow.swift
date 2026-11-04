import SwiftUI

// Reviews & refund — Figma section 8 · Reviews and refund (node 703:3017)
//
// Artboards:
//   703-3018  8.1 James · Push · rate Thomas
//   691-6828  8.2 James · Rate Thomas
//   703-3041  8.3 James · Rate Thomas · filled
//   691-6916  8.4 James · Review submitted
//   703-3129  8.5 Thomas · Push · rate James
//   691-6963  8.6 Thomas · Rate James
//   703-3152  8.7 Thomas · Review submitted
//   691-6764  8.8 Both · Timeline · deposit refunded
//   691-7051  8.9 James · Profile

struct ReviewsFlow: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: BorroStore

    var startScreen: String? = nil

    @State private var stack: [String] = []

    // James rates Thomas
    @State private var thomasScores: [Int] = [0, 0, 0, 0, 0]
    @State private var thomasComment: String = ""
    @State private var thomasArrangementRequired = true

    // Thomas rates James
    @State private var jamesScores: [Int] = [5, 5, 5, 5, 5]
    @State private var jamesComment: String = "James returned the steamer clean and on time. Thank you!"

    private let entry = "703-3018"
    private let known = [
        "703-3018", "691-6828", "703-3041", "691-6916", "703-3129",
        "691-6963", "703-3152", "691-6764", "691-7051"
    ]

    var body: some View {
        ZStack {
            currentScreen
        }
        .bBackground()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showsTabBar {
                ReviewsFlowTabBar(selected: selectedTab) { tab in
                    select(tab)
                }
            }
        }
        .onAppear(perform: applyStartScreen)
    }

    // MARK: - State machine

    private var current: String { stack.last ?? entry }

    private var isPushScreen: Bool { current == "703-3018" || current == "703-3129" }
    private var showsTabBar: Bool { !isPushScreen }

    private var selectedTab: AppTab {
        current == "691-7051" ? .you : .borro
    }

    private func go(_ slug: String) {
        withAnimation(.easeOut(duration: 0.2)) { stack.append(slug) }
    }

    private func back() {
        if stack.count > 1 {
            withAnimation(.easeOut(duration: 0.2)) { _ = stack.removeLast() }
        } else {
            router.pop()
        }
    }

    private func select(_ tab: AppTab) {
        if tab == .you && current != "691-7051" {
            go("691-7051")
        } else if tab != selectedTab {
            router.switchTab(tab)
        }
    }

    private func applyStartScreen() {
        guard stack.isEmpty else { return }
        guard let slug = startScreen, known.contains(slug) else {
            stack = [entry]
            return
        }
        switch slug {
        case "703-3041":
            thomasScores = [5, 5, 5, 5, 5]
            thomasComment = "So helpful and clear with the arrangements. Thank you!"
            thomasArrangementRequired = false
        case "691-6828":
            thomasScores = [0, 0, 0, 0, 0]
            thomasComment = ""
            thomasArrangementRequired = true
        case "691-6963":
            jamesScores = [5, 5, 5, 5, 5]
            jamesComment = "James returned the steamer clean and on time. Thank you!"
        default:
            break
        }
        stack = [slug]
    }

    // MARK: - Routing

    @ViewBuilder
    private var currentScreen: some View {
        switch current {
        case "703-3018":
            pushLockScreen(
                title: "How was Thomas's steamer?",
                message: "Return confirmed. Tap to rate your borrowing and help neighbours borrow with confidence.",
                footer: "Thomas · Garment Steamer · 18–19 Oct"
            ) {
                thomasScores = [0, 0, 0, 0, 0]
                thomasComment = ""
                go("691-6828")
            }
        case "691-6828", "703-3041":
            ratingScreen(
                subject: "Thomas",
                avatar: .thomas,
                largeIdentity: true,
                arrangementRequired: thomasArrangementRequired,
                scores: $thomasScores,
                comment: $thomasComment
            ) {
                go("691-6916")
            }
        case "691-6916":
            submittedScreen(
                subject: "Thomas",
                backTitle: "Back to My Borrowing",
                next: "703-3129"
            )
        case "703-3129":
            pushLockScreen(
                title: "How was James with your steamer?",
                message: "Return confirmed. Tap to rate James. Your review updates his credibility score.",
                footer: "James · Garment Steamer · 18–19 Oct"
            ) {
                jamesScores = [5, 5, 5, 5, 5]
                jamesComment = "James returned the steamer clean and on time. Thank you!"
                go("691-6963")
            }
        case "691-6963":
            ratingScreen(
                subject: "James",
                avatar: .james,
                largeIdentity: false,
                arrangementRequired: true,
                scores: $jamesScores,
                comment: $jamesComment
            ) {
                go("703-3152")
            }
        case "703-3152":
            submittedScreen(
                subject: "James",
                backTitle: "Back to My Lending",
                next: "691-6764"
            )
        case "691-6764":
            refundedTimelineScreen
        case "691-7051":
            jamesProfileScreen
        default:
            Color.clear
        }
    }

    // MARK: - Push lock screen (8.1 / 8.5)

    private func pushLockScreen(
        title: String,
        message: String,
        footer: String,
        onOpen: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geo in
                BImageView(photo: .lockScreen, cornerRadius: 0)
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "lock")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.top, 14)

                Text("Monday, 19 October")
                    .font(BFont.regular(19))
                    .foregroundStyle(.white)
                    .padding(.top, 18)

                Text("11:05")
                    .font(BFont.bold(76))
                    .foregroundStyle(.white)
                    .padding(.top, 0)

                notificationCard(title: title, message: message, footer: footer, onOpen: onOpen)
                    .padding(.top, 18)

                Text("Tap to respond")
                    .font(BFont.regular(12))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 18)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.top, 4)
        }
        .background(BColor.ink)
        .preferredColorScheme(.dark)
    }

    private func notificationCard(
        title: String,
        message: String,
        footer: String,
        onOpen: @escaping () -> Void
    ) -> some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(.white)
                        .frame(width: 28, height: 28)
                        .overlay {
                            BorroRoundMark()
                                .stroke(BColor.brand, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 20, height: 20)
                        }

                    Text("BORRO")
                        .font(BFont.bold(13))
                        .foregroundStyle(BColor.ink)
                    Spacer(minLength: 0)
                    Text("now")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                }

                Text(title)
                    .font(BFont.bold(16))
                    .foregroundStyle(BColor.ink)
                    .multilineTextAlignment(.leading)

                Text(message)
                    .font(BFont.regular(14))
                    .foregroundStyle(BColor.ink)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(footer)
                    .font(BFont.bold(13))
                    .foregroundStyle(BColor.brand)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.94))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rating screen (8.2 / 8.3 / 8.6)

    private func ratingScreen(
        subject: String,
        avatar: BPhoto,
        largeIdentity: Bool,
        arrangementRequired: Bool,
        scores: Binding<[Int]>,
        comment: Binding<String>,
        onSubmit: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            BAppBar(title: "Rate \(subject)", subtitle: "A little feedback goes a long way", backAction: back)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ratingIdentity(subject: subject, avatar: avatar, largeIdentity: largeIdentity)

                    VStack(spacing: 8) {
                        ratingRow("Overall rating*", index: 0, scores: scores)
                        ratingRow("Item condition*", index: 1, scores: scores)
                        ratingRow(arrangementRequired ? "Arrangement*" : "Arrangement", index: 2, scores: scores)
                        ratingRow("Punctuality*", index: 3, scores: scores)
                        ratingRow("Friendliness*", index: 4, scores: scores)
                    }

                    Text("* Required")
                        .font(BFont.regular(12))
                        .foregroundStyle(BColor.inkSecondary)

                    Text("Comment (optional)")
                        .font(BFont.bold(13))
                        .foregroundStyle(BColor.ink)

                    commentField(comment)

                    Text("Your ratings update \(subject)'s credibility score.")
                        .font(BFont.regular(13))
                        .foregroundStyle(BColor.brand)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)

            ReviewsFlowActionButton(
                title: "Submit Review",
                enabled: scores.wrappedValue.allSatisfy { $0 > 0 },
                action: onSubmit
            )
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
    }

    private func ratingIdentity(subject: String, avatar: BPhoto, largeIdentity: Bool) -> some View {
        HStack(alignment: .top, spacing: 16) {
            BAvatarView(photo: avatar, initials: subject == "Thomas" ? "TL" : "JC", size: 72)

            if largeIdentity {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Rate \(subject)")
                        .font(BFont.bold(24))
                        .foregroundStyle(BColor.ink)
                    Text("Garment Steamer")
                        .font(BFont.bold(24))
                        .foregroundStyle(BColor.ink)
                    Text("18–19 Oct 2026")
                        .font(BFont.bold(24))
                        .foregroundStyle(BColor.ink)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rate \(subject)")
                        .font(BFont.bold(24))
                        .foregroundStyle(BColor.ink)
                    Text("Garment Steamer")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.inkSecondary)
                    Text("18–19 Oct 2026")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.inkSecondary)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private func ratingRow(_ title: String, index: Int, scores: Binding<[Int]>) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(BFont.semibold(12))
                .foregroundStyle(BColor.ink)
                .frame(width: 125, alignment: .leading)

            HStack(spacing: 1) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        scores.wrappedValue[index] = star
                    } label: {
                        Image(systemName: star <= scores.wrappedValue[index] ? "star.fill" : "star")
                            .font(.system(size: 27, weight: .regular))
                            .foregroundStyle(star <= scores.wrappedValue[index] ? starGold : BColor.inkSecondary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(height: 44)
    }

    private var starGold: Color { Color(hex: 0xF5A524) }

    private func commentField(_ text: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text("Share your experience…")
                    .font(BFont.regular(15))
                    .foregroundStyle(BColor.inkSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .allowsHitTesting(false)
            }
            TextField("", text: text, axis: .vertical)
                .font(BFont.regular(15))
                .foregroundStyle(BColor.ink)
                .lineLimit(1...4)
                .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    // MARK: - Review submitted (8.4 / 8.7)

    private func submittedScreen(subject: String, backTitle: String, next: String) -> some View {
        VStack(spacing: 0) {
            BAppBar(title: "Review submitted", subtitle: "A little feedback goes a long way", backAction: back)

            ScrollView {
                VStack(spacing: 12) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(BColor.successSoft)
                                .frame(width: 74, height: 74)
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(BColor.brand)
                        }

                        Text("Thank you for your review!")
                            .font(BFont.bold(25))
                            .foregroundStyle(BColor.ink)

                        Text("Your feedback helps neighbours borrow with confidence.")
                            .font(BFont.regular(16))
                            .foregroundStyle(BColor.inkSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 42)
                    .padding(.bottom, 42)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(subject) · Garment Steamer")
                            .font(BFont.bold(18))
                            .foregroundStyle(BColor.ink)
                        Text("Your review has been saved · 19 Oct 2026")
                            .font(BFont.regular(13))
                            .foregroundStyle(BColor.inkSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(BColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                            .stroke(BColor.stroke, lineWidth: 0.7)
                    }
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)

            ReviewsFlowActionButton(title: backTitle) {
                go(next)
            }
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
    }

    // MARK: - 8.8 Timeline · deposit refunded

    private var refundedTimelineScreen: some View {
        VStack(spacing: 0) {
            BAppBar(title: "Timeline", subtitle: "Garment Steamer · BR-20481", backAction: back)

            ScrollView {
                VStack(spacing: 10) {
                    milestoneStrip

                    HStack(spacing: 12) {
                        BImageView(photo: .steamer, cornerRadius: 10)
                            .frame(width: 78, height: 68)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Garment Steamer")
                                .font(BFont.bold(18))
                                .foregroundStyle(BColor.ink)
                            Text("Completed")
                                .font(BFont.bold(18))
                                .foregroundStyle(BColor.ink)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(BColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                            .stroke(BColor.stroke, lineWidth: 0.7)
                    }

                    HStack(spacing: 10) {
                        BAvatarView(photo: BPeople.thomas.photo, initials: BPeople.thomas.initials, size: 38)
                        HStack(spacing: 5) {
                            Text("Thomas")
                                .font(BFont.bold(15))
                                .foregroundStyle(BColor.ink)
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(BColor.ink)
                            Text("★ 5.0 · 10 reviews")
                                .font(BFont.bold(15))
                                .foregroundStyle(BColor.ink)
                        }
                        Spacer(minLength: 0)
                        Button {
                            router.push(.person(BPeople.thomas))
                        } label: {
                            Text("View profile")
                                .font(BFont.bold(11))
                                .foregroundStyle(BColor.brand)
                        }
                        .buttonStyle(.plain)
                    }

                    handoverDetailsCard

                    timelineOutlineButton("View Agreement") {
                        router.push(.flow(.agreement, screen: "691-5763"))
                    }
                    timelineOutlineButton("Before / After · View condition photos") {
                        router.push(.flow(.handover, screen: nil))
                    }

                    HStack {
                        Text("Deposit Status · Refunded")
                            .font(BFont.bold(14))
                            .foregroundStyle(BColor.ink)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(BColor.successSoft)
                    .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)

            HStack(spacing: 10) {
                ReviewsFlowActionButton(title: "View borrowing summary", fullWidth: false) {
                    router.switchTab(.borro)
                }
                .frame(width: 223)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
    }

    private var milestoneStrip: some View {
        HStack(spacing: 6) {
            ForEach(["Agreed", "Meet-up", "Lending", "Return"], id: \.self) { label in
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(BColor.brand)
                        .frame(height: 4)
                    Text(label)
                        .font(BFont.semibold(10))
                        .foregroundStyle(BColor.ink)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 31, alignment: .top)
    }

    private var handoverDetailsCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                Text("Pickup").foregroundStyle(BColor.inkSecondary)
                Text("·").foregroundStyle(BColor.inkSecondary)
                Text("18 Oct · 7:30 pm").foregroundStyle(BColor.ink).fontWeight(.semibold)
            }
            HStack(spacing: 5) {
                Text("Return").foregroundStyle(BColor.inkSecondary)
                Text("·").foregroundStyle(BColor.inkSecondary)
                Text("19 Oct · 11:00 pm").foregroundStyle(BColor.ink).fontWeight(.semibold)
            }
            HStack(spacing: 5) {
                Image(systemName: "scope")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(BColor.ink)
                Text("Block A Security Desk")
                    .foregroundStyle(BColor.ink)
                    .fontWeight(.semibold)
            }
        }
        .font(BFont.regular(14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    private func timelineOutlineButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
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

    // MARK: - 8.9 James · Profile

    private var jamesProfileScreen: some View {
        VStack(spacing: 0) {
            HStack {
                BorroWordmark(height: 34)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BSpace.screen)
            .frame(height: 64)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 15) {
                        BAvatarView(photo: .james, initials: "JC", size: 70)

                        VStack(alignment: .leading, spacing: 5) {
                            Text("James Chong")
                                .font(BFont.bold(23))
                                .foregroundStyle(BColor.ink)
                            Text("21 · Singapore")
                                .font(BFont.regular(14))
                                .foregroundStyle(BColor.inkSecondary)
                            Text("✓ Identity verified")
                                .font(BFont.bold(11))
                                .foregroundStyle(Color(hex: 0x1E8E5A))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(BColor.successSoft)
                                .clipShape(Capsule())
                        }
                        Spacer(minLength: 0)
                    }

                    Text("Co-living, campus days & sharing more.")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.inkSecondary)

                    credibilityCard

                    profileMenuCard
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var credibilityCard: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .top) {
                ZStack(alignment: .top) {
                    Circle()
                        .trim(from: 0.5, to: 1.0)
                        .stroke(BColor.stroke, style: StrokeStyle(lineWidth: 13, lineCap: .butt))
                    Circle()
                        .trim(from: 0.5, to: 0.5 + 0.5 * 0.72)
                        .stroke(BColor.brand, style: StrokeStyle(lineWidth: 13, lineCap: .butt))
                }
                .frame(width: 170, height: 170)
                .frame(width: 170, height: 85, alignment: .top)

                VStack(spacing: 2) {
                    Text("72/100")
                        .font(BFont.bold(25))
                        .foregroundStyle(BColor.ink)
                    HStack(spacing: 4) {
                        Text("Moderate")
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.brand)
                        Image(systemName: "info.circle")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(BColor.brand)
                    }
                }
                .padding(.top, 38)
            }
            .frame(height: 114, alignment: .top)
            .frame(maxWidth: .infinity)

            Text("72/100 · Moderate · Keep sharing thoughtfully.")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    private var profileMenuCard: some View {
        VStack(spacing: 10) {
            profileRow(icon: "shippingbox", title: "My Listings") {
                router.switchTab(.lend)
            }
            profileRow(icon: "handshake", title: "My Borrowing") {
                router.switchTab(.borro)
            }
            profileRow(icon: "heart", title: "Wishlist") {
                router.push(.flow(.other, screen: "708-3039"))
            }
            profileRow(icon: "star", title: "Reviews") {}
            profileRow(icon: "creditcard", title: "Payment methods") {}
            profileRow(icon: "gearshape", title: "Settings") {}
            profileRow(icon: "questionmark.circle", title: "Help") {}
        }
        .padding(12)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    private func profileRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(BColor.brand)
                    .frame(width: 20)
                Text(title)
                    .font(BFont.regular(15))
                    .foregroundStyle(BColor.ink)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(BColor.inkTertiary)
            }
            .frame(height: 40)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Local components

private struct ReviewsFlowActionButton: View {
    var title: String
    var enabled: Bool = true
    var height: CGFloat = 48
    var fullWidth: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BFont.bold(15))
                .foregroundStyle(enabled ? .white : BColor.inkSecondary)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.horizontal, fullWidth ? 0 : 20)
                .frame(height: height)
                .background(enabled ? BColor.brand : BColor.surfaceAlt)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

private struct ReviewsFlowTabBar: View {
    var selected: AppTab
    var onSelect: (AppTab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(BColor.stroke)
                .frame(height: 1)
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        onSelect(tab)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.safeIcon(selected: selected == tab))
                                .font(.system(size: 21, weight: .regular))
                                .frame(height: 24)
                            Text(tab.rawValue)
                                .font(BFont.tabLabel)
                        }
                        .foregroundStyle(selected == tab ? BColor.brand : BColor.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(BColor.surface)
    }
}

/// The Borro circular mark (used at app-icon size in push cards, and after the
/// wordmark in the You app bar). Drawn locally because the bundled wordmark
/// bitmap has an opaque background.
private struct BorroRoundMark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.addArc(
            center: center,
            radius: radius - 1,
            startAngle: .degrees(40),
            endAngle: .degrees(320),
            clockwise: false
        )
        return path
    }
}

private struct BorroWordmark: View {
    var height: CGFloat = 34

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            Text("Borr")
                .font(BFont.extraBold(height * 0.66))
                .foregroundStyle(BColor.brand)
            BorroRoundMark()
                .stroke(BColor.brand, style: StrokeStyle(lineWidth: height * 0.10, lineCap: .round))
                .frame(width: height * 0.52, height: height * 0.52)
        }
    }
}
