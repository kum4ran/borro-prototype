import SwiftUI

/// Figma frame "6.11 James · Collection · enter lender code" (node 691:6435).
struct S6_11_CollectionEnterLenderCodeView: View {
    var body: some View {
        PhotoStepPage(flow: .collection, slot: .front, codeLocked: true) {
            LenderCodeEntryTop(failed: false)
        }
    }
}

#Preview {
    PreviewHost(.s6_11)
}
