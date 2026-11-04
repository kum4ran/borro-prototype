import SwiftUI

/// Figma frame "6.4 Thomas · Front photo added" (node 704:484).
struct S6_4_FrontPhotoAddedView: View {
    var body: some View {
        PhotoStepPage(flow: .dropOff, slot: .front) {
            LenderCodeTop()
        }
    }
}

#Preview {
    PreviewHost(.s6_4)
}
