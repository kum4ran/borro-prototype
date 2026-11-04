import SwiftUI

/// Figma frame "4.5 James · Return times (pop-up)" (node 701:762).
/// CONFLICT: Figma shows morning return times; the default offers centre on Scenario.defaultReturnTime (11:00 pm).
struct S4_5_ReturnTimesPopUpView: View {
    var body: some View {
        TimeSheet(kind: .returned)
    }
}

#Preview {
    PreviewHost(.s4_5)
}
