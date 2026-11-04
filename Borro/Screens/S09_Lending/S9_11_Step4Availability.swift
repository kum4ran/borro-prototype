import SwiftUI

/// Figma frame "9.11 Thomas · Step 4 availability" (node 708:1214).
struct S9_11_Step4AvailabilityView: View {
    var body: some View {
        ListingStepPage(step: 4, caption: "Item Availability", heading: "When is it available?",
                        subheading: "Choose the dates your steamer can be borrowed.", backTo: .s9_10, next: .s9_12) {
            CalendarMonth(selected: Set(13...27))
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Available \(MockData.listingAvailability)").font(.b(.s14)).foregroundStyle(Color.ink)
                Text("Tap available dates to block them out.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        }
    }
}

#Preview {
    PreviewHost(.s9_11)
}
