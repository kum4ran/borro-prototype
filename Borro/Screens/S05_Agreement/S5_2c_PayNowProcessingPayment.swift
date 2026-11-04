import SwiftUI

/// Figma frame "5.2c James · PayNow · Processing payment" (node 902:330). Auto-advances after 2 s.
struct S5_2c_PayNowProcessingPaymentView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Processing payment", subtitle: "Deposit · Ref #\(Scenario.reference)")
        } content: {
            ProgressView()
                .controlSize(.large)
                .tint(Color.brand)
                .frame(width: Size.seal, height: Size.seal)
                .background(Color.brandSoft, in: Circle())
                .frame(maxWidth: .infinity)
                .padding(.top, Space.x24)
                .accessibilityIdentifier("paymentSpinner")
            VStack(spacing: Space.x12) {
                Text("Confirming your payment").font(.b(.s22)).foregroundStyle(Color.ink)
                Text("Waiting for PayNow to confirm your \(Scenario.depositAmountExact) deposit. Please don't close the app.")
                    .font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
        .task {
            try? await Task.sleep(for: .seconds(Scenario.paymentProcessingSeconds))
            guard router.visible == .s5_2c else { return }
            appState.depositPaid()
            router.go(.s5_2d)
        }
    }
}

#Preview {
    PreviewHost(.s5_2c)
}
