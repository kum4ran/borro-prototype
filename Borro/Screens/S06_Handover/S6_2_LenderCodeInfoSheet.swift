import SwiftUI

/// Figma frame "6.2 Thomas · Lender code info (sheet)" (node 703:434).
struct S6_2_LenderCodeInfoSheetView: View {
    var body: some View {
        InfoSheet(title: "My lender code", subtitle: "Meet In Person First",
                  message: "Show this code to the borrower only when you meet in person. They enter it on their phone to confirm the handover.",
                  done: .s6_1)
    }
}

#Preview {
    PreviewHost(.s6_2)
}
