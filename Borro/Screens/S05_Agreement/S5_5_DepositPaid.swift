import SwiftUI

/// Figma frame "5.5 James · Deposit paid" (node 691:6006). Same page as 5.2 once the deposit is held.
struct S5_5_DepositPaidView: View {
    var body: some View {
        FinalAgreementPage()
    }
}

#Preview {
    PreviewHost(.s5_5) { $0.depositPaid() }
}
