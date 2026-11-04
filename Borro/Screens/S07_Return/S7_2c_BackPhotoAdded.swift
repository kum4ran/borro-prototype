import SwiftUI

/// Figma frame "7.2c Thomas · Back photo added" (node 736:2046).
struct S7_2c_BackPhotoAddedView: View {
    var body: some View {
        PhotoStepPage(flow: .returned, slot: .back) {
            BorrowerCodeEntryTop()
        }
    }
}

#Preview {
    PreviewHost(.s7_2c)
}
