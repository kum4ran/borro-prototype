import SwiftUI

/// Figma frame "9.8 Thomas · List an Item · Step 1 photos" (node 708:1002).
struct S9_8_ListAnItemStep1PhotosView: View {
    var body: some View {
        ListingStepPage(step: 1, caption: "Upload Pictures", heading: "Make a great first impression",
                        subheading: "Add up to 6 clear photos. Your first photo becomes the cover.", next: .s9_9) {
            PhotoView(photo: .listPhoto1)
                .frame(height: Size.listingHero)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            Chip(text: "Cover", fill: .successFill, ink: .success)
            HStack(spacing: Space.x8) {
                ForEach(0..<2, id: \.self) { _ in
                    PhotoView(photo: .listPhoto2)
                        .frame(height: Size.listingThumb)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
                }
                VStack(spacing: Space.x2) {
                    IconView(icon: .plus, size: Size.iconSmall).foregroundStyle(Color.brand)
                    Text("3 of 6 photos").font(.r(.s10)).foregroundStyle(Color.inkSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: Size.listingThumb)
                .background(Color.successFill, in: RoundedRectangle(cornerRadius: Radius.photo))
            }
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Good photos build trust").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("Show the item, accessories and any existing marks.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        }
    }
}

#Preview {
    PreviewHost(.s9_8)
}
