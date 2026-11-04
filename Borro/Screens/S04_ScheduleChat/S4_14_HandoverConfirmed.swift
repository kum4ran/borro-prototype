import SwiftUI

/// Figma frame "4.14 Both · Handover confirmed" (node 701:1718).
struct S4_14_HandoverConfirmedView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    private let thomas = MockData.thomas

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Handover confirmed", subtitle: "James & Thomas · Garment Steamer")
        } content: {
            InfoBanner(icon: .check, title: "Both confirmed",
                       message: "Thomas and James confirmed this arrangement.")
            HandoverSummaryCard(rows: ScheduleRows.agreed(appState))
            PersonStrip(user: thomas, line: "★ \(thomas.rating) · \(thomas.reviewCount) reviews")
        } actions: {
            SecondaryButton(title: "Chat with Thomas") { router.go(.s4_9) }
            PrimaryButton(title: "View Final Agreement", identifier: "viewFinalAgreementButton") { router.go(.s5_2) }
        }
    }
}

#Preview {
    PreviewHost(.s4_14)
}
