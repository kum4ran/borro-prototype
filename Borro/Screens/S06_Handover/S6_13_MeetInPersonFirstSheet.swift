import SwiftUI

/// Figma frame "6.13 James · Meet in person first (sheet)" (node 703:2171).
struct S6_13_MeetInPersonFirstSheetView: View {
    var body: some View {
        InfoSheet(title: "Meet in person first",
                  message: "Ask your lender to show their code when you meet in person. Enter the 4-digit code on your phone to confirm the handover.",
                  warning: "Never ask for, share or enter a meet-up code remotely.",
                  done: .s6_11)
    }
}

#Preview {
    PreviewHost(.s6_13)
}
