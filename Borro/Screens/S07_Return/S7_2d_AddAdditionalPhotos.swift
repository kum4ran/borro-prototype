import SwiftUI

/// Figma frame "7.2d Thomas · Add additional photos" (node 736:2150).
struct S7_2d_AddAdditionalPhotosView: View {
    var body: some View {
        PhotoStepPage(flow: .returned, slot: .extra) {
            BorrowerCodeEntryTop()
        }
    }
}

#Preview {
    PreviewHost(.s7_2d)
}
