import SwiftUI

/// Figma frame "6.14d James · Add additional photos" (node 736:1738).
struct S6_14d_AddAdditionalPhotosView: View {
    var body: some View {
        PhotoStepPage(flow: .collection, slot: .extra) {
            VerifiedCodeTop(title: "Enter lender code", code: Scenario.lenderCode, infoTarget: .s6_13)
        }
    }
}

#Preview {
    PreviewHost(.s6_14d)
}
