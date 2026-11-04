import SwiftUI

/// Figma frame "5.1 Thomas · Agreement sent" (node 691:5698).
/// CONFLICT: Figma shows "Deposit paid" before James pays; here it follows the deposit state.
struct S5_1_AgreementSentView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Final Agreement", subtitle: "James · Borrower / Thomas · Lender")
        } content: {
            AgreementItemCard(dates: "\(appState.pickUpDay.withYear), \(appState.pickUpTime) → \(appState.returnDay.short), \(appState.returnTime)",
                              place: appState.meetUpPlace)
            Text("Safety Deposit: \(Scenario.depositAmount)").font(.b(.s18)).foregroundStyle(Color.ink)
            DepositPaidPanel(paid: appState.deposit != .unpaid, method: appState.paymentMethod)
            VStack(alignment: .leading, spacing: Space.x6) {
                Text("Thomas's care instructions").font(.b(.s13)).foregroundStyle(Color.ink)
                Text(TermsContent.careNoteShort).font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle(shadow: false)
            TermsCard { router.go(.s5_2e) }
        } actions: {
            PrimaryButton(title: "Edit Agreement") {}
            SecondaryButton(title: "Chat with James") { router.go(.s4_9) }
        }
    }
}

#Preview {
    PreviewHost(.s5_1)
}
