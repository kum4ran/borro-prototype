import SwiftUI

/// Figma frame "1.3 James · Filter menu" (node 691:4365). Dropdown over 1.2.
struct S1_3_FilterMenuView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    private var options: [(title: String, value: String)] {
        [("Location", appState.radius.phrase.prefix(1).uppercased() + appState.radius.phrase.dropFirst()),
         ("Rating", "4 stars & up"), ("Reviews", "Most reviewed"), ("Availability", appState.borrowRangeShort)]
    }

    var body: some View {
        OverlayContainer(alignment: .topTrailing, dimmed: false) {
            VStack(spacing: Space.x2) {
                ForEach(options, id: \.title) { option in
                    TapArea(accessibilityLabel: "\(option.title), \(option.value)") {
                        // Figma wires Location only.
                        if option.title == "Location" { router.go(.s1_4) }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: Space.x2) {
                                Text(option.title).font(.b(.s14)).foregroundStyle(Color.ink)
                                Text(option.value).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                            }
                            Spacer()
                            IconView(icon: .chevronRight, size: Size.iconSmall).foregroundStyle(Color.ink)
                        }
                        .frame(minHeight: Size.filterRow)
                    }
                    .accessibilityIdentifier("filter.\(option.title)")
                }
            }
            .padding(Space.x12)
            .frame(width: Size.filterMenuWidth)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.card))
            .raisedShadow()
            .padding(.top, Size.filterMenuTop)
            .padding(.trailing, Space.gutter)
        }
    }
}

#Preview {
    PreviewHost(.s1_3)
}
