import SwiftUI

/// Figma frame "9.10 Thomas · Step 3 pick-up" (node 708:1135).
/// CONFLICT: Figma lists "West Wing Lobby"; the brief uses Block A Security Desk everywhere.
struct S9_10_Step3PickUpView: View {
    var body: some View {
        ListingStepPage(step: 3, caption: "Select Location", heading: "Preferred meeting spot", backTo: .s9_9, next: .s9_11) {
            Text("Pickup address").font(.b(.s13)).foregroundStyle(Color.ink)
            AddressField(text: "\(Scenario.area), Singapore")
            MapCard(height: Size.meetingMap)
            PickOnMapButton {}
            LabeledField(label: "Meet-up spot", value: Scenario.meetUpPlace)
            Text("Your exact pickup details are shared after acceptance.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
        }
    }
}

#Preview {
    PreviewHost(.s9_10)
}
