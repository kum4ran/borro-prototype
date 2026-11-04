import SwiftUI

/// Figma frame "6.1 Thomas · Drop-off · lender code" (node 691:6129).
struct S6_1_DropOffLenderCodeView: View {
    var body: some View {
        PhotoStepPage(flow: .dropOff, slot: .front) {
            LenderCodeTop()
        }
    }
}

#Preview {
    PreviewHost(.s6_1)
}
