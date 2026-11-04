import SwiftUI

/// Figma frame "4.13 Thomas · Request changes (branch)" (node 701:1626).
struct S4_13_RequestChangesBranchView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    /// Thomas's suggestion; nil means "Arrange via chat".
    @State private var spot: MeetingSpot? = .blockA

    var body: some View {
        ScreenScaffold(gutter: Space.gutterNarrow) {
            BackAppBar(title: "Request changes", subtitle: "James · Garment Steamer")
        } content: {
            VStack(spacing: Space.x8) {
                AvailabilityField(title: "Pick-up · 2026", count: "\(appState.pickUpOffers.count) times", day: appState.pickUpDay.medium,
                                  pills: appState.pickUpOffers.map(\.pill),
                                  footnote: "\(appState.pickUpOffers.count) selected · \(appState.pickUpOffers.count) match James")
                AvailabilityField(title: "Return · 2026", count: "\(appState.returnOffers.count) times", day: appState.returnDay.medium,
                                  pills: appState.returnOffers.map(\.pill),
                                  footnote: "\(appState.returnOffers.count) selected · \(appState.returnOffers.count) match James")
            }
            FieldLabel(text: "Meeting address")
            AddressField(text: spot?.name ?? "Arrange via chat")
            PickOnMapButton { router.go(.s4_6) }
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Preferred meeting spot").font(.b(.s14)).foregroundStyle(Color.ink)
                ForEach(MeetingSpot.lenderChoices.map(Optional.some) + [nil], id: \.self) { option in
                    Button { spot = option } label: {
                        HStack(spacing: Space.x10) {
                            Circle().strokeBorder(Color.brand, lineWidth: Size.buttonStroke)
                                .overlay(Circle().fill(option == spot ? Color.brand : .clear).padding(Space.x4))
                                .frame(width: Size.iconSmall, height: Size.iconSmall)
                            Text(option?.name ?? "Arrange via chat").font(.r(.s14)).foregroundStyle(Color.ink)
                        }
                        .frame(minHeight: Size.hitTarget)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(option == spot ? .isSelected : [])
                    .accessibilityIdentifier("lenderSpot.\(option?.name ?? "chat")")
                }
            }
            .cardStyle(radius: Radius.r14)
        } actions: {
            PrimaryButton(title: "Send Changes") {
                if let spot { appState.chooseMeetUpSpot(spot) }
                router.go(spot == nil ? .s4_9 : .s4_11)
            }
        }
    }
}

#Preview {
    PreviewHost(.s4_13)
}
