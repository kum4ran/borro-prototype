import SwiftUI

/// Figma frame "9.15 Thomas · Step 8 terms" (node 708:1574).
struct S9_15_Step8TermsView: View {
    @State private var agreed = true

    var body: some View {
        ListingStepPage(step: 8, caption: "Terms and Conditions", heading: "One last thing", backTo: .s9_14,
                        action: "Preview listing", next: .s9_16) {
            VStack(alignment: .leading, spacing: Space.x10) {
                Text("Lending on Borro").font(.b(.s14)).foregroundStyle(Color.ink)
                ForEach(Self.paragraphs, id: \.self) {
                    Text($0).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                }
            }
            .cardStyle(shadow: false)
            CheckboxRow(text: "I agree to the Borro Terms & Conditions and community guidelines.", checked: agreed) {
                agreed.toggle()
            }
            Text("Read the full Terms & Conditions ↗").font(.r(.s12)).foregroundStyle(Color.brand)
        }
    }

    static let paragraphs = [
        "You confirm that this item is safe, clean and yours to lend. Describe its condition honestly and agree on handover details with your borrower.",
        "Use the one-time handover code and required condition photos. Deposits are held securely until the safe return is confirmed.",
        "If something goes wrong, report it through Borro so both sides can resolve it fairly.",
    ]
}

#Preview {
    PreviewHost(.s9_15)
}
