import SwiftUI

/// Figma frame "6.14c James · Back photo added" (node 736:1634).
struct S6_14c_BackPhotoAddedView: View {
    var body: some View {
        PhotoStepPage(flow: .collection, slot: .back) {
            VerifiedCodeTop(title: "Enter lender code", code: Scenario.lenderCode, infoTarget: .s6_13)
        }
    }
}

#Preview {
    PreviewHost(.s6_14c)
}
