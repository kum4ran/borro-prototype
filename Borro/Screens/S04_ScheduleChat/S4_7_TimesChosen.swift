import SwiftUI

/// Figma frame "4.7 James · Times chosen" (node 701:1059).
struct S4_7_TimesChosenView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold(gutter: Space.gutterNarrow) {
            ArrangeHandoverBar()
        } content: {
            ProposalFields()
            PickOnMapButton { router.go(.s4_6) }
        } actions: {
            PrimaryButton(title: "Send Proposal", enabled: appState.canSendProposal, identifier: "sendProposalButton") {
                router.go(.s4_8)
            }
        }
    }
}

/// Pick-up and return fields with James's offered times, plus the address. Tapping a field reopens its sheet.
struct ProposalFields: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        TapArea(accessibilityLabel: "Pick-up times") { router.go(.s4_2) } label: {
            AvailabilityField(title: "Pick-up", count: timesCount(appState.pickUpOffers.count),
                              day: appState.pickUpDay.medium, pills: appState.pickUpOffers.map(\.pill))
        }
        TapArea(accessibilityLabel: "Return times") { router.go(.s4_4) } label: {
            AvailabilityField(title: "Return", count: timesCount(appState.returnOffers.count),
                              day: appState.returnDay.medium, pills: appState.returnOffers.map(\.pill))
        }
        FieldLabel(text: "Meeting address")
        AddressField(text: appState.meetUpPlace)
    }

    private func timesCount(_ n: Int) -> String { n == 1 ? "1 time" : "\(n) times" }
}

#Preview {
    PreviewHost(.s4_7)
}
