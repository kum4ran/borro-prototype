import SwiftUI

/// Figma frame "7.2b Thomas · Back photo (empty)" (node 736:1945).
struct S7_2b_BackPhotoEmptyView: View {
    var body: some View {
        PhotoStepPage(flow: .returned, slot: .back) {
            BorrowerCodeEntryTop()
        }
    }
}

#Preview {
    PreviewHost(.s7_2b)
}
