import SwiftUI

/// Figma frame "9.16 Thomas · Listing preview" (node 708:1634).
struct S9_16_ListingPreviewView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BigBackAppBar(title: "Preview listing", backTo: .s9_15)
        } content: {
            PhotoView(photo: .listPhoto3)
                .frame(height: Size.listingHero)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            Text(MockData.steamer.title).font(.b(.s22)).foregroundStyle(Color.ink)
            Chip(text: "Like new · Home & living", fill: .successFill, ink: .success)
            Text(MockData.listingDescription).font(.r(.s13)).foregroundStyle(Color.ink)
            VStack(spacing: Space.x12) {
                KeyValueRow(key: "Pickup", value: "\(Scenario.meetUpPlace), \(Scenario.area)")
                KeyValueRow(key: "Available", value: MockData.listingAvailability)
                KeyValueRow(key: "Maximum period", value: MockData.maxBorrowDays)
                KeyValueRow(key: "Safety deposit", value: Scenario.depositAmount)
            }
            .cardStyle()
            Text("3 photos · 3 care instructions · Terms accepted").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
        } actions: {
            PrimaryButton(title: "Publish", identifier: "publishButton") { router.go(.s9_17) }
        }
    }
}

#Preview {
    PreviewHost(.s9_16)
}
