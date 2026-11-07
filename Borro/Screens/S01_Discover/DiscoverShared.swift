import SwiftUI

/// Shared body of the Home frames 1.1, 1.2 and 1.5: logo bar, search, controls, heading, grid.
struct DiscoverPage<Grid: View>: View {
    @Environment(Router.self) private var router
    @Binding var searchText: String
    let needItNow: Bool
    let heading: String
    var count: String?
    var onToggle: () -> Void
    var onFilter: (() -> Void)?
    var onSearch: (() -> Void)? = nil
    @ViewBuilder var grid: () -> Grid

    var body: some View {
        ScreenScaffold {
            BrandAppBar(heartTarget: .s11_4)
        } content: {
            SearchBar(text: $searchText, onSearch: onSearch)
            DiscoveryControls(needItNow: needItNow, onToggle: onToggle, onFilter: onFilter)
            HStack(alignment: .firstTextBaseline) {
                SectionTitle(text: heading)
                Spacer()
                if let count {
                    Text(count).font(.m(.s12)).foregroundStyle(Color.inkSecondary)
                }
            }
            grid()
        }
    }
}

extension Router {
    func openListing(_ listing: Listing) {
        appState?.selectListing(listing)
        go(.s2_1)
    }
}
