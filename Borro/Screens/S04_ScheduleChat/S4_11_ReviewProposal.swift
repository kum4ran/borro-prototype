import SwiftUI

/// Figma frame "4.11 Thomas · Review proposal" (node 701:1366).
struct S4_11_ReviewProposalView: View {
    @Environment(Router.self) private var router
    private let james = MockData.james

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Review proposal", subtitle: "James & Thomas · Garment Steamer")
        } content: {
            InfoBanner(title: "James is waiting for you",
                       message: "James sent you a proposal. Pick one pick-up and one return time to accept.")
            HandoverSummaryCard(rows: ScheduleRows.offered)
            PersonStrip(user: james, line: "★ \(james.rating) · \(james.reviewCount) reviews") { router.go(.s3_4) }
        } actions: {
            HStack(spacing: Space.x8) {
                SecondaryButton(title: "Request changes") { router.go(.s4_13) }
                SecondaryButton(title: "Chat with James") { router.go(.s4_9) }
            }
            PrimaryButton(title: "Accept proposal", identifier: "acceptProposalButton") { router.go(.s4_12) }
        }
    }
}

#Preview {
    PreviewHost(.s4_11)
}
