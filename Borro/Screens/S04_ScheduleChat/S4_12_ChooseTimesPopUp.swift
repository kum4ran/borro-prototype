import SwiftUI

/// Figma frame "4.12 Thomas · Choose times (pop-up)" (node 701:1464).
/// Mirrors the "Borro times" variables: one pick-up and one return pill, then Confirm.
struct S4_12_ChooseTimesPopUpView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        SheetContainer(title: "Choose your times", subtitle: "Tap one pick-up time and one return time.") {
            VStack(spacing: Space.x12) {
                choiceGroup(title: "Pick-up", day: MockData.pickUpDay, options: MockData.pickUpOptions,
                            selected: appState.pickUpChoice) { appState.choosePickUp($0) }
                choiceGroup(title: "Return", day: MockData.returnDay, options: MockData.returnOptions,
                            selected: appState.returnChoice) { appState.chooseReturn($0) }
                Spacer(minLength: 0)
                PrimaryButton(title: appState.timesButtonLabel, enabled: appState.bothTimesChosen,
                              identifier: "confirmTimesButton") {
                    router.go(.s4_14)
                }
            }
        }
    }

    private func choiceGroup(title: String, day: String, options: [TimeOption], selected: TimeOption?,
                             choose: @escaping (TimeOption) -> Void) -> some View {
        VStack(alignment: .leading, spacing: Space.x12) {
            HStack {
                Text(title).font(.b(.s15)).foregroundStyle(Color.ink)
                Spacer()
                Text("Choose one").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            HStack(spacing: Space.x8) {
                Text(day).font(.b(.s13)).foregroundStyle(Color.ink).fixedSize()
                ForEach(options) { option in
                    BigTimePill(label: option.label, selected: selected == option) { choose(option) }
                }
                Spacer(minLength: 0)
            }
        }
        .panel(.surfaceSunk, padding: Space.x14, radius: Radius.r16)
    }
}

#Preview {
    PreviewHost(.s4_12)
}
