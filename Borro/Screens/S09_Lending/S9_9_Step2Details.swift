import SwiftUI

/// Figma frame "9.9 Thomas · Step 2 details" (node 708:1065).
struct S9_9_Step2DetailsView: View {
    var body: some View {
        ListingStepPage(step: 2, caption: "Item Description", heading: "Tell us about your item", backTo: .s9_8, next: .s9_10) {
            LabeledField(label: "Item name", value: MockData.steamer.title)
            LabeledField(label: "Category", value: "Home & living", dropdown: true)
            LabeledField(label: "Description", value: MockData.listingDescription, multiline: true)
            LabeledField(label: "Condition", value: "Like new", dropdown: true)
            Text("Used twice. No scratches or leaks.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
        }
    }
}

#Preview {
    PreviewHost(.s9_9)
}
