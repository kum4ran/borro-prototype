import SwiftUI

/// Figma frame "9.12 Thomas · Step 5 period" (node 708:1363).
struct S9_12_Step5PeriodView: View {
    var body: some View {
        ListingStepPage(step: 5, caption: "Borrowing Limit", heading: "Set a borrowing limit",
                        subheading: "Keep each borrow short and sweet. Borrowers can request up to this many days.",
                        backTo: .s9_11, next: .s9_13) {
            VStack(spacing: Space.x8) {
                Text("Maximum borrow period").font(.r(.s13)).foregroundStyle(Color.ink)
                HStack {
                    stepButton("−")
                    Spacer()
                    Text(MockData.maxBorrowDays).font(.b(.s29)).foregroundStyle(Color.ink)
                    Spacer()
                    stepButton("+")
                }
            }
            .cardStyle(padding: Space.x16)
        }
    }

    private func stepButton(_ symbol: String) -> some View {
        Text(symbol).font(.r(.s22)).foregroundStyle(Color.brand)
            .frame(width: Size.icon + Space.x4, height: Size.icon + Space.x4)
            .overlay(Circle().strokeBorder(Color.brand, lineWidth: Size.buttonStroke))
            .frame(minWidth: Size.hitTarget, minHeight: Size.hitTarget)
    }
}

#Preview {
    PreviewHost(.s9_12)
}
