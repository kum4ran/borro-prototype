import SwiftUI

/// Figma frame "7.3 Thomas · Return photo added" (node 703:2785).
struct S7_3_ReturnPhotoAddedView: View {
    var body: some View {
        PhotoStepPage(flow: .returned, slot: .extra) {
            BorrowerCodeEntryTop()
        }
    }
}

#Preview {
    PreviewHost(.s7_3)
}
