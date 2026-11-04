import SwiftUI

/// Figma frame "1.1 James · Home" (node 691:4139).
struct S1_1_HomeView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        DiscoverPage(needItNow: false, heading: "Good things, nearby") {
            appState.setNeedItNow(true)
            router.go(.s1_2)
        } grid: {
            ListingGrid(listings: MockData.homeFeed) { router.openListing($0) }
        }
    }
}

#Preview {
    PreviewHost(.s1_1)
}
