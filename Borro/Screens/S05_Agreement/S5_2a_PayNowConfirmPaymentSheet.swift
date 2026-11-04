import SwiftUI

/// Figma frame "5.2a James · PayNow · Confirm payment (sheet)" (node 902:185). Sheet over 5.2.
struct S5_2a_PayNowConfirmPaymentSheetView: View {
    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(title: "Pay deposit with PayNow") {
            VStack(spacing: Space.x16) {
                Text("Your \(Scenario.depositAmountExact) deposit for the Garment Steamer is held securely by Borro and refunded within 1 working day after a successful return.")
                    .font(.r(.s14)).foregroundStyle(Color.inkSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                PrimaryButton(title: "Pay \(Scenario.depositAmountExact) with PayNow", identifier: "payWithPayNowButton") {
                    router.go(.s5_2b)
                }
                SecondaryButton(title: "Cancel") { router.go(.s5_2) }
            }
        }
    }
}

#Preview {
    PreviewHost(.s5_2a)
}
