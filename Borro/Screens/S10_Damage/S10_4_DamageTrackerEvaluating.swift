import SwiftUI

/// Figma frame "10.4 James · Damage tracker · evaluating" (node 708:2017).
struct S10_4_DamageTrackerEvaluatingView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Damage report", subtitle: "Garment Steamer · \(Scenario.reference)", backTo: .s10_3)
        } content: {
            InfoBanner(icon: .info, title: "Evaluating damage", message: "Our team is reviewing the damage and comparing the condition photos.")
            VStack(alignment: .leading, spacing: Space.x14) {
                Text("Your report’s progress").font(.b(.s16)).foregroundStyle(Color.ink)
                CheckpointList(items: [("Report submitted", .done),
                                       ("Evaluating damage", .current),
                                       ("Verifying information", .waiting),
                                       ("Outcome", .waiting)]) { index in
                    if index == 1 { router.go(.s10_5) }
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
    PreviewHost(.s10_4)
}
