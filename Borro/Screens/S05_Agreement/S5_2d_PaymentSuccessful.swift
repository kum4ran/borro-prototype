import SwiftUI

/// Figma frame "5.2d James · Payment successful" (node 902:385).
struct S5_2d_PaymentSuccessfulView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Payment successful", subtitle: "\(Scenario.reference) · \(Scenario.borrowDatesShort)")
        } content: {
            ResultSeal(icon: .check, fill: .successMint, tint: .brand)
            VStack(spacing: Space.x8) {
                Text("Deposit paid").font(.b(.s22)).foregroundStyle(Color.ink)
                Text("Your \(Scenario.depositAmountExact) deposit is held securely by Borro until the steamer is returned.")
                    .font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: Space.x10) {
                Text("Payment receipt").font(.b(.s16)).foregroundStyle(Color.ink)
                DotRow(label: "Item", value: "Garment Steamer")
                DotRow(label: "Amount", value: Scenario.depositAmountSGD)
                DotRow(label: "Method", value: "PayNow")
                DotRow(label: "Reference", value: "#\(Scenario.reference)")
                Text("Refunded within 1 working day after return").font(.r(.s13)).foregroundStyle(Color.ink)
            }
            .cardStyle()
        } actions: {
            PrimaryButton(title: "Continue", identifier: "paymentContinueButton") { router.go(.s5_5) }
        }
    }
}

#Preview {
    PreviewHost(.s5_2d)
}
