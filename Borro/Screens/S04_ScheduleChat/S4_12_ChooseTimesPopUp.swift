import SwiftUI

/// Figma frame "4.12 Thomas · Choose times (pop-up)" (node 701:1464).
/// Mirrors the "Borro times" variables: one pick-up and one return pill, then Confirm.
struct S4_12_ChooseTimesPopUpView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        SheetContainer(title: "Choose your times", subtitle: "Tap one pick-up time and one return time.") {
            VStack(spacing: Space.x12) {
                choiceGroup(title: "Pick-up", day: appState.pickUpDay.medium, options: appState.pickUpOffers,
                            selected: appState.pickUpChoice) { appState.choosePickUp($0) }
                choiceGroup(title: "Return", day: appState.returnDay.medium, options: appState.returnOffers,
                            selected: appState.returnChoice) { appState.chooseReturn($0) }
                Spacer(minLength: 0)
                PrimaryButton(title: appState.timesButtonLabel, enabled: appState.bothTimesChosen,
                              identifier: "confirmTimesButton") {
                    router.go(.s4_14)
                }
            }
        }
    }

    private func choiceGroup(title: String, day: String, options: [TimeOfDay], selected: TimeOfDay?,
                             choose: @escaping (TimeOfDay) -> Void) -> some View {
        VStack(alignment: .leading, spacing: Space.x12) {
            HStack {
                Text(title).font(.b(.s15)).foregroundStyle(Color.ink)
                Spacer()
                Text("Choose one").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            // One row as in Figma; stacks when large text no longer fits.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Space.x8) {
                    Text(day).font(.b(.s13)).foregroundStyle(Color.ink).fixedSize()
                    pills(options, selected: selected, choose: choose)
                    Spacer(minLength: 0)
                }
                VStack(alignment: .leading, spacing: Space.x8) {
                    Text(day).font(.b(.s13)).foregroundStyle(Color.ink)
                    FlowLayout(spacing: Space.x8) { pills(options, selected: selected, choose: choose) }
                }
            }
        }
        .panel(.surfaceSunk, padding: Space.x14, radius: Radius.r16)
    }

    private func pills(_ options: [TimeOfDay], selected: TimeOfDay?, choose: @escaping (TimeOfDay) -> Void) -> some View {
        ForEach(options) { option in
            BigTimePill(label: option.pill, selected: selected == option) { choose(option) }
        }
    }
}

#Preview {
    PreviewHost(.s4_12)
}
