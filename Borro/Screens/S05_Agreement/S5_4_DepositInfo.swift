import SwiftUI

/// Figma frame "5.4 James · Deposit info" (node 691:5930). Sheet over 5.2.
struct S5_4_DepositInfoView: View {
    var body: some View {
        SheetContainer(title: "Held securely by Borro") {
            Text(TermsContent.depositInfo).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
        }
    }
}

#Preview {
    PreviewHost(.s5_4)
}
