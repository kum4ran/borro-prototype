import SwiftUI

/// Figma frame "4.8 James · Proposal sent" (node 701:1177).
struct S4_8_ProposalSentView: View {
    @Environment(Router.self) private var router
    private let thomas = MockData.thomas

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Proposal sent", subtitle: "James & Thomas · Garment Steamer")
        } content: {
            // Figma: tapping the banner is the simulated jump to Thomas's phone (4.11).
            TapArea(accessibilityLabel: "Waiting for Thomas. Open Thomas’s view") { router.go(.s4_11) } label: {
                InfoBanner(title: "Waiting for Thomas",
                           message: "Thomas will pick one pick-up and one return time from the options you offered.")
            }
            .accessibilityIdentifier("waitingForThomasBanner")
            HandoverSummaryCard(rows: ScheduleRows.offered)
            PersonStrip(user: thomas, line: "★ \(thomas.rating) · \(thomas.reviewCount) reviews")
        } actions: {
            PrimaryButton(title: "Edit proposal") { router.go(.s4_7) }
        }
    }
}

enum ScheduleRows {
    /// Rows while James's offer is open (4.8, 4.11).
    static let offered: [(String, String)] = [
        ("Borrower", MockData.james.name), ("Lender", MockData.thomas.name),
        ("Pick-up", "\(MockData.pickUpDay) · \(MockData.pickUpOffer)"),
        ("Return", "\(MockData.returnDay) · \(MockData.returnOffer)"),
        ("Meet at", Scenario.meetUpPlace),
    ]

    /// Rows once times are agreed (4.14).
    @MainActor static func agreed(_ state: AppState) -> [(String, String)] {
        [("Borrower", MockData.james.name), ("Lender", MockData.thomas.name),
         ("Pick-up", state.pickUpLabel), ("Return", state.returnLabel), ("Meet at", Scenario.meetUpPlace)]
    }
}

#Preview {
    PreviewHost(.s4_8)
}
