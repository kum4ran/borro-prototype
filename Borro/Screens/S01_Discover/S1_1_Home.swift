import SwiftUI

/// Figma frame "1.1 James · Home" (node 691:4139).
struct S1_1_HomeView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @State private var searchText: String = ""

    private var allListings: [Listing] {
        let base = [MockData.jbl, MockData.projector, MockData.projectorScreen, MockData.football, MockData.steamer, MockData.xiaomiSteamer, MockData.camera] + appState.customListings
        var seen = Set<String>()
        var list: [Listing] = []
        for item in base {
            if !seen.contains(item.id) {
                seen.insert(item.id)
                list.append(item)
            }
        }
        return list
    }

    private var filteredListings: [Listing] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            return allListings.filter {
                $0.title.lowercased().contains(query) ||
                $0.resolvedDescription.lowercased().contains(query) ||
                $0.area.lowercased().contains(query) ||
                $0.owner.name.lowercased().contains(query)
            }
        }
        return MockData.homeFeed + appState.customListings
    }

    private var headingText: String {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            return "Results for ‘\(query)’"
        }
        return "Good things, nearby"
    }

    var body: some View {
        DiscoverPage(searchText: $searchText,
                     needItNow: false,
                     heading: headingText,
                     count: !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(filteredListings.count) item\(filteredListings.count == 1 ? "" : "s")" : nil) {
            appState.setNeedItNow(true)
            router.go(.s1_2)
        } onFilter: {
            router.go(.s1_3)
        } onSearch: {
            // fuzzy filtering in real-time
        } grid: {
            if filteredListings.isEmpty {
                VStack(spacing: Space.x12) {
                    IconView(icon: .search, size: Size.avatarLarge).foregroundStyle(Color.inkSecondary)
                    Text("No items found").font(.b(.s16)).foregroundStyle(Color.ink)
                    Text("Try searching for 'steamer', 'projector', 'speaker', or 'camera'.").font(.r(.s13)).foregroundStyle(Color.inkSecondary).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Space.x32)
                .cardStyle()
            } else {
                ListingGrid(listings: filteredListings, showsDistance: false) { router.openListing($0) }
            }
        }
    }
}

#Preview {
    PreviewHost(.s1_1)
}
