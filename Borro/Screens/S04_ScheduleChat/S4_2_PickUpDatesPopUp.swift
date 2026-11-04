import SwiftUI

/// Figma frame "4.2 James · Pick-up dates (pop-up)" (node 701:284).
struct S4_2_PickUpDatesPopUpView: View {
    var body: some View {
        DateSheet(title: "Pick-up dates", subtitle: "Tap the day you can pick it up.",
                  selectedDay: 18, summary: MockData.pickUpDay, next: .s4_3)
    }
}

#Preview {
    PreviewHost(.s4_2)
}
