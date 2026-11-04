import SwiftUI

/// Figma frame "6.14 James · Code verified" (node 703:2262).
struct S6_14_CodeVerifiedView: View {
    var body: some View {
        PhotoStepPage(flow: .collection, slot: .front) {
            VerifiedCodeTop(title: "Enter lender code", code: Scenario.lenderCode, infoTarget: .s6_13)
        }
    }
}

#Preview {
    PreviewHost(.s6_14)
}
