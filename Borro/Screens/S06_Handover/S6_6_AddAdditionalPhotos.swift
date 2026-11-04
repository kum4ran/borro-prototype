import SwiftUI

/// Figma frame "6.6 Thomas · Add additional photos" (node 703:765).
struct S6_6_AddAdditionalPhotosView: View {
    var body: some View {
        PhotoStepPage(flow: .dropOff, slot: .extra) {
            LenderCodeTop()
        }
    }
}

#Preview {
    PreviewHost(.s6_6)
}
