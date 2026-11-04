import SwiftUI

/// Figma frame "6.15 James · Photo added" (node 703:2430).
struct S6_15_PhotoAddedView: View {
    var body: some View {
        PhotoStepPage(flow: .collection, slot: .extra) {
            VerifiedCodeTop(title: "Enter lender code", code: Scenario.lenderCode, infoTarget: .s6_13)
        }
    }
}

#Preview {
    PreviewHost(.s6_15)
}
