import SwiftUI

/// Figma frame "4.5 James · Return times (pop-up)" (node 701:762).
/// CONFLICT: Figma's wheel and chips show morning times; the scenario return is 11:00 pm.
struct S4_5_ReturnTimesPopUpView: View {
    var body: some View {
        TimeSheet(title: "Return times", subtitle: "After your first pick-up (\(Scenario.pickUp)).",
                  dayChip: "\(MockData.returnDay) · 3", day: MockData.returnDay,
                  hours: ["21", "22", Scenario.returnTime24, "00", "01"], addLabel: "Add \(Scenario.returnTime)",
                  addEnabled: false, chips: MockData.returnOptions.map(\.time), back: .s4_4, next: .s4_6)
    }
}

#Preview {
    PreviewHost(.s4_5)
}
