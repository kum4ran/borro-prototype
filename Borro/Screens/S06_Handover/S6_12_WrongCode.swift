import SwiftUI

/// Figma frame "6.12 James · Wrong code" (node 703:2090).
struct S6_12_WrongCodeView: View {
    var body: some View {
        PhotoStepPage(flow: .collection, slot: .front, codeLocked: true) {
            LenderCodeEntryTop(failed: true)
        }
    }
}

#Preview {
    PreviewHost(.s6_12)
}
