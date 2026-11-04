import SwiftUI

/// Figma frame "5.6 James · Agreement submitted" (node 691:6074).
struct S5_6_AgreementSubmittedView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Agreement submitted", subtitle: "\(Scenario.reference) · \(Scenario.borrowDatesShort)")
        } content: {
            ResultSeal(icon: .check, fill: .successMint, tint: .brand)
            VStack(spacing: Space.x8) {
                Text("You're all agreed").font(.b(.s24)).foregroundStyle(Color.ink)
                Text("Your agreement is saved. Meet in person to confirm the handover.")
                    .font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: Space.x10) {
                Text("Garment Steamer").font(.b(.s16)).foregroundStyle(Color.ink)
                DotRow(label: "Borrower", value: MockData.james.name)
                DotRow(label: "Lender", value: MockData.thomas.name)
                DotRow(label: "Pickup", value: "18 Oct · \(appState.pickUpTime)")
                DotRow(label: "Return", value: "19 Oct · \(appState.returnTime)")
                Text("⌖ \(Scenario.meetUpPlace)").font(.r(.s13)).foregroundStyle(Color.ink)
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("✓ Deposit paid · \(Scenario.depositAmount) SGD").font(.b(.s13)).foregroundStyle(Color.successDeep)
                Text("PayNow · Ref #\(Scenario.reference) · Held securely by Borro").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        } actions: {
            PrimaryButton(title: "Go to handover", identifier: "goToTimelineButton") { router.go(.s5_7) }
        }
    }
}

#Preview {
    PreviewHost(.s5_6) { $0.depositPaid() }
}
