import SwiftUI

/// Figma frame "6.14a James · Front photo added" (node 736:1432).
struct S6_14a_FrontPhotoAddedView: View {
    var body: some View {
        PhotoStepPage(flow: .collection, slot: .front) {
            VerifiedCodeTop(title: "Enter lender code", code: Scenario.lenderCode, infoTarget: .s6_13)
        }
    }
}

#Preview {
    PreviewHost(.s6_14a)
}
