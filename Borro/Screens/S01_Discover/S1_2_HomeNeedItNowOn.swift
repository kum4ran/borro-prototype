import SwiftUI

/// Figma frame "1.2 James · Home · Need it Now on" (node 691:4256).
struct S1_2_HomeNeedItNowOnView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        DiscoverPage(needItNow: true, heading: "Available right now",
                     count: "\(MockData.needItNowFeed.count) results · all of Singapore") {
            appState.setNeedItNow(false)
            router.go(.s1_1)
        } onFilter: {
            router.go(.s1_3)
        } grid: {
            ListingGrid(listings: MockData.needItNowFeed, showsDistance: true) { router.openListing($0) }
        }
    }
}

#Preview {
    PreviewHost(.s1_2)
}
