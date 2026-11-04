import SwiftUI

/// Four-step progress header: Agreed, Meet-up, Lending, Return.
struct StageBar: View {
    let current: Int
    var titles = AppState.TimelineStage.allCases.map(\.title)

    var body: some View {
        HStack(alignment: .top, spacing: Space.x4) {
            ForEach(titles.indices, id: \.self) { i in
                VStack(spacing: Space.x6) {
                    Capsule().fill(i <= current ? Color.brand : Color.track).frame(height: Size.stepBar)
                    Text(titles[i])
                        .font(i == current ? .b(.s10) : .m(.s10))
                        .foregroundStyle(i == current ? Color.ink : Color.inkSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Stage \(current + 1) of \(titles.count): \(titles[current])")
    }
}

/// Body of the Timeline frames (5.7, 6.10a, 6.20, 7.6, 8.8), driven entirely by AppState.
struct BorrowTimeline: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    private let thomas = MockData.thomas

    var body: some View {
        let stage = appState.timelineStage
        let content = TimelineCopy.make(appState)
        ScreenScaffold {
            BackAppBar(title: "Timeline", subtitle: "Garment Steamer · \(Scenario.reference)")
        } content: {
            StageBar(current: stage.rawValue)
            HStack(spacing: Space.x12) {
                PhotoView(photo: .steamerDesk)
                    .frame(width: Size.thumb, height: Size.thumbSquare)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
                Text("Garment Steamer\n\(content.headline)").font(.b(.s18)).foregroundStyle(Color.ink)
                    .accessibilityIdentifier("timelineHeadline")
                Spacer(minLength: 0)
            }
            .cardStyle(padding: Space.x8, shadow: false)
            PersonStrip(user: thomas, line: "★ \(thomas.rating) · \(thomas.reviewCount) reviews")
            VStack(alignment: .leading, spacing: Space.x6) {
                DotRow(label: "Pickup", value: appState.pickUpShort)
                DotRow(label: "Return", value: appState.returnShort)
                Text("⌖ \(appState.meetUpPlace)").font(.r(.s13)).foregroundStyle(Color.ink)
            }
            .cardStyle(shadow: false)
            // Not wired in Figma.
            SecondaryButton(title: "View Agreement") {}
            SecondaryButton(title: "Before / After · View condition photos") {}
            Text("Deposit Status · \(appState.depositStatusText)")
                .font(.b(.s13)).foregroundStyle(Color.ink)
                .panel(.successFill, padding: Space.x10, radius: Radius.r8)
                .accessibilityIdentifier("depositStatus")
            if let note = content.note {
                Text(note).font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            if appState.deposit == .refunded && !appState.thomasReviewSubmitted {
                // Simulated jump: Thomas still has to rate James (8.5).
                TapArea(accessibilityLabel: "Thomas’s phone: How was James with your steamer?") { router.go(.s8_5) } label: {
                    HStack(spacing: Space.x10) {
                        BorroAppIcon()
                        VStack(alignment: .leading, spacing: Space.x2) {
                            Text("Meanwhile, on Thomas’s phone").font(.b(.s12)).foregroundStyle(Color.ink)
                            Text("How was James with your steamer?").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                        }
                        Spacer()
                        IconView(icon: .chevronRight, size: Size.iconSmall).foregroundStyle(Color.ink)
                    }
                    .panel(.brandMist)
                }
                .accessibilityIdentifier("thomasPushBanner")
            }
        } actions: {
            PrimaryButton(title: content.action, identifier: "timelineActionButton") { content.perform(appState, router) }
        }
    }
}

/// Copy and next step for each timeline state (strings from the Figma timeline frames).
struct TimelineCopy {
    let headline: String
    let note: String?
    let action: String
    let perform: @MainActor (AppState, Router) -> Void

    @MainActor static func make(_ state: AppState) -> TimelineCopy {
        let place = state.meetUpPlace
        switch state.timelineStage {
        case .agreed:
            return TimelineCopy(
                headline: "Handover pending",
                note: "Agreement signed and deposit paid. Meet Thomas at \(place) on \(state.pickUpDay.medium), \(state.pickUpTime).",
                action: "Go to handover") { _, router in router.go(.s6_1) }
        case .meetUp:
            return TimelineCopy(
                headline: "Meet-up in progress",
                note: "Thomas has dropped off the steamer. James enters the lender code to collect it.",
                action: "Collect steamer") { _, router in router.go(.s6_11) }
        case .lending:
            return TimelineCopy(
                headline: "Ongoing",
                note: "Handover confirmed by James and Thomas. Let the steamer cool, empty the tank and return the mitt.",
                action: "Ready to Return") { state, router in
                    state.setStatus(.returnPending)
                    router.go(.s7_1)
                }
        case .returned:
            if state.deposit == .refunded {
                return TimelineCopy(headline: "Completed", note: nil, action: "Back to My Borrowing") { _, router in
                    router.go(.s2_4)
                }
            }
            return TimelineCopy(headline: "Completed", note: nil, action: "Rate Thomas") { _, router in router.go(.s8_2) }
        }
    }
}
