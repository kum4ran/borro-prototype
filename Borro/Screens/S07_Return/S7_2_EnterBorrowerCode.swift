import SwiftUI

/// Figma frame "7.2 Thomas · Enter borrower code" (node 703:2705).
struct S7_2_EnterBorrowerCodeView: View {
    var body: some View {
        PhotoStepPage(flow: .returned, slot: .front) {
            BorrowerCodeEntryTop()
        }
    }
}

#Preview {
    PreviewHost(.s7_2)
}
