import SwiftUI

/// Figma frame "4.3 James · Pick-up times (pop-up)" (node 701:429).
struct S4_3_PickUpTimesPopUpView: View {
    var body: some View {
        TimeSheet(title: "Pick-up times", subtitle: "Pick a day, then add the times you can do.",
                  dayChip: "\(MockData.pickUpDay) · 2", day: MockData.pickUpDay,
                  hours: ["16", "17", "18", "19", "20"], addLabel: "Add 6:00 pm",
                  chips: MockData.pickUpOptions.map(\.time), back: .s4_2, next: .s4_4)
    }
}

#Preview {
    PreviewHost(.s4_3)
}
