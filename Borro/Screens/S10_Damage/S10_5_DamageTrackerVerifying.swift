import SwiftUI

/// Figma frame "10.5 James · Damage tracker · verifying" (node 708:2089).
struct S10_5_DamageTrackerVerifyingView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Damage report", subtitle: "Garment Steamer · \(Scenario.reference)", backTo: .s10_4)
        } content: {
            InfoBanner(icon: .info, title: "Verifying information", message: "We are checking the handover records and repair information with both members.")
            VStack(alignment: .leading, spacing: Space.x14) {
                Text("Your report’s progress").font(.b(.s16)).foregroundStyle(Color.ink)
                CheckpointList(items: [("Report submitted", .done),
                                       ("Evaluating damage", .done),
                                       ("Verifying information", .current),
                                       ("Outcome", .waiting)]) { index in
                    if index == 2 { router.go(.s10_7) }
                }
            }
            .cardStyle()
            InfoBanner(icon: .clock, title: "Next update expected by 21 Oct",
                       message: "We’ll notify you when the next checkpoint is complete. No repair balance is charged without separate consent.")
            Text("Submitted 19 Oct 2026 · \(Scenario.depositAmount) deposit held during assessment")
                .font(.r(.s11)).foregroundStyle(Color.inkSecondary)
        } actions: {
            PrimaryButton(title: "Chat with Thomas") { router.go(.s4_9) }
        }
    }
}

#Preview {
    PreviewHost(.s10_5)
}
