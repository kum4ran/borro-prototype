import SwiftUI

/// Figma frame "1.5 James · Results · steamer within 1 km" (node 691:4657).
struct S1_5_ResultsSteamerWithin1KmView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        DiscoverPage(query: "Garment steamer", needItNow: true, heading: "Steamers near Bencoolen",
                     count: "\(appState.steamerResults.count) result\(appState.steamerResults.count == 1 ? "" : "s") · \(appState.radius.phrase)") {
            router.go(.s1_1)
        } onFilter: {
            router.go(.s1_3)
        } grid: {
            ForEach(appState.steamerResults) { listing in
                ListingCard(listing: listing, showsDistance: true)
                    .contentShape(Rectangle())
                    .onTapGesture { router.openListing(listing) }
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
