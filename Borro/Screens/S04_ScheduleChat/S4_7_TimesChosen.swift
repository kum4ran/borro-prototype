import SwiftUI

/// Figma frame "4.7 James · Times chosen" (node 701:1059).
struct S4_7_TimesChosenView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold(gutter: Space.gutterNarrow) {
            ArrangeHandoverBar()
        } content: {
            ProposalFields()
            PickOnMapButton { router.go(.s4_6) }
        } actions: {
            PrimaryButton(title: "Send Proposal", identifier: "sendProposalButton") { router.go(.s4_8) }
        }
    }
}

/// Pick-up and return fields with James's offered times, plus the address.
struct ProposalFields: View {
    var body: some View {
        AvailabilityField(title: "Pick-up", count: "\(MockData.pickUpOptions.count) times",
                          day: MockData.pickUpDay, pills: MockData.pickUpOptions.map(\.label))
        AvailabilityField(title: "Return", count: "\(MockData.returnOptions.count) times",
                          day: MockData.returnDay, pills: MockData.returnOptions.map(\.label))
        FieldLabel(text: "Meeting address")
        AddressField(text: Scenario.meetUpPlace)
    }
}

#Preview {
    PreviewHost(.s4_7)
}
