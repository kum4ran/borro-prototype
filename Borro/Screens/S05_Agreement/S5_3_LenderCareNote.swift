import SwiftUI

/// Figma frame "5.3 James · Lender care note" (node 691:5836). Sheet over 5.2.
struct S5_3_LenderCareNoteView: View {
    var body: some View {
        SheetContainer(title: "Thomas's care instructions", subtitle: "Garment Steamer") {
            VStack(spacing: Space.x16) {
                Text(TermsContent.careNote)
                    .font(.r(.s16)).foregroundStyle(Color.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle(padding: Space.x14, shadow: false)
                HStack(spacing: Space.x8) {
                    // Copy and Download are not wired in Figma.
                    SecondaryButton(title: "Copy") {}
                    PrimaryButton(title: "Download") {}
                }
            }
        }
    }
}

#Preview {
    PreviewHost(.s5_3)
}
