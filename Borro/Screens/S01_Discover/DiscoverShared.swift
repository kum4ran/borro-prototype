import SwiftUI

/// Shared body of the Home frames 1.1, 1.2 and 1.5: logo bar, search, controls, heading, grid.
struct DiscoverPage<Grid: View>: View {
    var query: String?
    let needItNow: Bool
    let heading: String
    var count: String?
    var onToggle: () -> Void
    var onFilter: (() -> Void)?
    @ViewBuilder var grid: () -> Grid

    var body: some View {
        ScreenScaffold {
            BrandAppBar(heartTarget: .s11_4)
        } content: {
            SearchBar(query: query)
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
    /// Only the garment steamer has a details page in Figma.
    func openListing(_ listing: Listing) {
        if listing.id == MockData.steamer.id { go(.s2_1) }
    }
}
