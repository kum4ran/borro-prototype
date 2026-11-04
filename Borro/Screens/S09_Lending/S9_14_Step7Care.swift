import SwiftUI

/// Figma frame "9.14 Thomas · Step 7 care" (node 708:1510).
struct S9_14_Step7CareView: View {
    var body: some View {
        ListingStepPage(step: 7, caption: "Care Instructions", heading: "Help them care for it",
                        subheading: "These numbered instructions become your Lender’s Note in the agreement.",
                        backTo: .s9_13, next: .s9_15) {
            ForEach(MockData.careInstructions.indices, id: \.self) { i in
                LabeledField(label: "Care instruction \(i + 1)", value: MockData.careInstructions[i])
            }
            SecondaryButton(title: "+ Add instruction") {}
        }
    }
}

#Preview {
    PreviewHost(.s9_14)
}
