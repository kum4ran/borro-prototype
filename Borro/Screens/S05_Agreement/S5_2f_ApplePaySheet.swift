import SwiftUI

/// App-only frame "5.2f James · Apple Pay (sheet)". Figma draws the Apple Pay button on 5.2 but never
/// wires it; this simulated sheet gives that option its own path: confirm → 5.2c processing → 5.2d receipt.
/// No real payment or Wallet access happens.
struct S5_2f_ApplePaySheetView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        SheetContainer {
            VStack(alignment: .leading, spacing: Space.x16) {
                HStack {
                    HStack(spacing: Space.x2) {
                        Image(systemName: "apple.logo").font(.b(.s20))
                        Text("Pay").font(.inter(.semibold, .s22))
                    }
                    .foregroundStyle(Color.inkBlack)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Apple Pay")
                    Spacer()
                    LinkButton(title: "Cancel", font: .s(.s15)) { router.go(.s5_2) }
                        .accessibilityIdentifier("applePayCancel")
                }
                VStack(spacing: 0) {
                    row("Card", "Card in Wallet")
                    Divider1()
                    row("Merchant", "Borro · deposit for Garment Steamer")
                    Divider1()
                    row("Reference", "#\(Scenario.reference)")
                }
                .cardStyle(padding: Space.x12, shadow: false)
                HStack(alignment: .firstTextBaseline) {
                    Text("Pay Borro").font(.r(.s15)).foregroundStyle(Color.inkSecondary)
                    Spacer()
                    Text(Scenario.depositAmountSGD).font(.b(.s22)).foregroundStyle(Color.ink)
                }
                Text("Held by Borro and refunded within 1 working day after a successful return.")
                    .font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                PrimaryButton(title: "Pay with Apple Pay", fill: .inkBlack, identifier: "confirmApplePayButton") {
                    appState.choosePaymentMethod(.applePay)
                    router.go(.s5_2c)
                }
                Text("Prototype: no card is charged.").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func row(_ key: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(key).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                .frame(width: Size.summaryLabel, alignment: .leading)
            Text(value).font(.s(.s13)).foregroundStyle(Color.ink)
            Spacer(minLength: 0)
        }
        .frame(minHeight: Size.hitTarget)
    }
}

#Preview {
    PreviewHost(.s5_2f)
}
