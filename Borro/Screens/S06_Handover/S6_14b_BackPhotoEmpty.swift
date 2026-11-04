import SwiftUI

/// Figma frame "6.14b James · Back photo (empty)" (node 736:1533).
struct S6_14b_BackPhotoEmptyView: View {
    var body: some View {
        PhotoStepPage(flow: .collection, slot: .back) {
            VerifiedCodeTop(title: "Enter lender code", code: Scenario.lenderCode, infoTarget: .s6_13)
        }
    }
}

#Preview {
    PreviewHost(.s6_14b)
}
