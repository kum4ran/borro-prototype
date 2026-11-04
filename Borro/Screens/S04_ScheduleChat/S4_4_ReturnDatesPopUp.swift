import SwiftUI

/// Figma frame "4.4 James · Return dates (pop-up)" (node 701:585).
struct S4_4_ReturnDatesPopUpView: View {
    var body: some View {
        DateSheet(title: "Return dates", subtitle: "Tap every day you can take it back (after your first pick-up).",
                  selectedDay: 19, summary: MockData.returnDay, next: .s4_5)
    }
}

#Preview {
    PreviewHost(.s4_4)
}
