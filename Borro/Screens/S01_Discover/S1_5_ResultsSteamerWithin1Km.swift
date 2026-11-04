import SwiftUI

/// Figma frame "1.5 James · Results · steamer within 1 km" (node 691:4657).
struct S1_5_ResultsSteamerWithin1KmView: View {
    @Environment(Router.self) private var router

    var body: some View {
        DiscoverPage(query: "Garment steamer", needItNow: true, heading: "Steamers near Bencoolen",
                     count: "\(MockData.resultsFeed.count) result") {
            router.go(.s1_1)
        } onFilter: {
            router.go(.s1_3)
        } grid: {
            ForEach(MockData.resultsFeed) { listing in
                ListingCard(listing: listing, showsDistance: true)
                    .contentShape(Rectangle())
                    .onTapGesture { router.go(.s2_1) }
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("listing.\(listing.id)")
            }
        }
    }
}

#Preview {
    PreviewHost(.s1_5)
}
