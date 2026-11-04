import SwiftUI

/// Figma frame "4.1 James · Propose handover" (node 701:203).
struct S4_1_ProposeHandoverView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold(gutter: Space.gutterNarrow) {
            ArrangeHandoverBar()
        } content: {
            Text("A convenient place. A time that works for both.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            VStack(alignment: .leading, spacing: Space.x12) {
                FieldLabel(text: "Pick-up")
                TapArea(accessibilityLabel: "Pick-up, select date and time") { router.go(.s4_2) } label: {
                    SelectRow(text: "Select date and time")
                }
                .accessibilityIdentifier("pickUpRow")
                FieldLabel(text: "Return")
                SelectRow(text: "Select date and time", enabled: false)
                Text("Choose pick-up first. Return times open up after it.").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle(padding: Space.x14, radius: Radius.r18)
            FieldLabel(text: "Meeting address")
            AddressField(text: appState.meetUpChosen ? appState.meetUpPlace : "Not set yet", placeholder: !appState.meetUpChosen)
            PickOnMapButton { router.go(.s4_6) }
        } actions: {
            MutedButton(title: "Send Proposal") {}
        }
    }
}

#Preview {
    PreviewHost(.s4_1)
}
