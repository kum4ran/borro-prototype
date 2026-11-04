import SwiftUI

/// Figma frame "7.2a Thomas · Front photo added" (node 736:1844).
struct S7_2a_FrontPhotoAddedView: View {
    var body: some View {
        PhotoStepPage(flow: .returned, slot: .front) {
            BorrowerCodeEntryTop()
        }
    }
}

#Preview {
    PreviewHost(.s7_2a)
}
