import SwiftUI

/// Figma frame "4.13 Thomas · Request changes (branch)" (node 701:1626).
struct S4_13_RequestChangesBranchView: View {
    @Environment(Router.self) private var router
    @State private var spot = 1
    private let spots = ["West Wing Lobby", Scenario.meetUpPlace, "Arrange via chat"]

    var body: some View {
        ScreenScaffold(gutter: Space.gutterNarrow) {
            BackAppBar(title: "Request changes", subtitle: "James · Garment Steamer")
        } content: {
            VStack(spacing: Space.x8) {
                AvailabilityField(title: "Pick-up · 2026", count: "2 times", day: MockData.pickUpDay,
                                  pills: MockData.pickUpOptions.map(\.label), footnote: "2 selected · 2 match James")
                AvailabilityField(title: "Return · 2026", count: "1 time", day: MockData.returnDay,
                                  pills: [Scenario.returnPill], footnote: "1 selected · 1 match James")
            }
            FieldLabel(text: "Meeting address")
            AddressField(text: Scenario.meetUpPlace)
            PickOnMapButton { router.go(.s4_6) }
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Preferred meeting spot").font(.b(.s14)).foregroundStyle(Color.ink)
                ForEach(spots.indices, id: \.self) { i in
                    Button { spot = i } label: {
                        HStack(spacing: Space.x10) {
                            Circle().strokeBorder(Color.brand, lineWidth: Size.buttonStroke)
                                .overlay(Circle().fill(i == spot ? Color.brand : .clear).padding(Space.x4))
                                .frame(width: Size.iconSmall, height: Size.iconSmall)
                            Text(spots[i]).font(.r(.s14)).foregroundStyle(Color.ink)
                        }
                        .frame(minHeight: Size.hitTarget)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(i == spot ? .isSelected : [])
                }
            }
            .cardStyle(radius: Radius.r14)
        } actions: {
            PrimaryButton(title: "Send Changes") { router.go(.s4_11) }
        }
    }
}

#Preview {
    PreviewHost(.s4_13)
}
