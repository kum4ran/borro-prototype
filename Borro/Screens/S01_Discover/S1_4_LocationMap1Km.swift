import SwiftUI

/// Figma frame "1.4 James · Location map · 1 km" (node 691:4492). Sheet over 1.2.
struct S1_4_LocationMap1KmView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        SheetContainer(title: "Find it close to you", showsClose: true) {
            VStack(alignment: .leading, spacing: Space.x16) {
                VStack(alignment: .leading, spacing: Space.x8) {
                    Text("Location").font(.b(.s13)).foregroundStyle(Color.ink)
                    InputBox(text: "Search location…", icon: .search)
                }
                MapCard()
                VStack(alignment: .leading, spacing: Space.x16) {
                    Text("Search radius").font(.b(.s13)).foregroundStyle(Color.ink)
                    RadiusSlider(stops: RadiusStop.allCases.map(\.label), selected: appState.radius.rawValue) {
                        if let stop = RadiusStop(rawValue: $0) { appState.setRadius(stop) }
                    }
                }
                InputBox(text: "Custom radius, e.g. 1.5", trailing: "km")
                Text("✓ Searching \(appState.radius.phrase) of \(Scenario.area)")
                    .font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                VStack(spacing: Space.x16) {
                    PrimaryButton(title: "Search", identifier: "locationSearchButton") { router.go(.s1_5) }
                    SecondaryButton(title: "Cancel") { router.go(.s1_2) }
                }
            }
        }
    }
}

#Preview {
    PreviewHost(.s1_4)
}
