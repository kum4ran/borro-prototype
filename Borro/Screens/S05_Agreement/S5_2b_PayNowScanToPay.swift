import SwiftUI

/// Figma frame "5.2b James · PayNow · Scan to pay" (node 902:266).
struct S5_2b_PayNowScanToPayView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Pay with PayNow", subtitle: "Deposit · Ref #\(Scenario.reference)", backTo: .s5_2)
        } content: {
            VStack(spacing: Space.x12) {
                Text("Scan to pay \(Scenario.depositAmountExact)").font(.b(.s16)).foregroundStyle(Color.ink)
                QRCodeView(payload: Scenario.payNowQRPayload)
                    .frame(width: Size.qr, height: Size.qr)
                    .overlay {
                        RoundedRectangle(cornerRadius: Radius.r4).fill(Color.payNowPurple)
                            .frame(width: Space.x20, height: Space.x20)
                            .overlay(RoundedRectangle(cornerRadius: Radius.r4).strokeBorder(Color.surface, lineWidth: Size.mapDotStroke))
                    }
                    .accessibilityIdentifier("payNowQR")
                Text("Open your banking app, choose PayNow and scan this code.")
                    .font(.r(.s12)).foregroundStyle(Color.inkSecondary).multilineTextAlignment(.center)
                Text("Code expires in \(Scenario.payNowExpiry)").font(.b(.s12)).foregroundStyle(Color.ink)
            }
            .frame(maxWidth: .infinity)
            .cardStyle(padding: Space.x16)
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Amount due · \(Scenario.depositAmountSGD)").font(.b(.s14)).foregroundStyle(Color.ink)
                Text("To Borro · Ref #\(Scenario.reference) · refunded after return").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.brandMist)
        } actions: {
            PrimaryButton(title: "I've paid", identifier: "iHavePaidButton") { router.go(.s5_2c) }
            SecondaryButton(title: "Cancel payment") { router.go(.s5_2) }
        }
    }
}

#Preview {
    PreviewHost(.s5_2b)
}
