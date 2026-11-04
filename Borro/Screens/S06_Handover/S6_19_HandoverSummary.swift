import SwiftUI

/// Figma frame "6.19 Both · Handover summary" (node 691:6511).
struct S6_19_HandoverSummaryView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Handover summary", subtitle: "Garment Steamer · \(Scenario.reference)")
        } content: {
            InfoBanner(icon: .check, title: "Both confirmed", message: "Thomas and James confirmed the in-person collection.")
            VStack(alignment: .leading, spacing: Space.x10) {
                HStack(spacing: Space.x12) {
                    PhotoView(photo: .steamerDesk)
                        .frame(width: Size.thumbSquare, height: Size.thumbSquare)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
                    VStack(alignment: .leading, spacing: Space.x4) {
                        Text("Garment Steamer").font(.b(.s16)).foregroundStyle(Color.ink)
                        Text("Thomas → James").font(.r(.s12)).foregroundStyle(Color.ink)
                        Chip(text: "Ongoing", fill: appState.status.chipFill, ink: appState.status.chipInk)
                    }
                }
                DotRow(label: "Pickup", value: "\(appState.pickUpDay.withYear) · \(appState.pickUpTime)")
                DotRow(label: "Return", value: "\(appState.returnDay.withYear) · \(appState.returnTime)")
                Text(appState.meetUpPlace).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x10) {
                Text("Condition records · Both confirmed").font(.b(.s13)).foregroundStyle(Color.ink)
                conditionRecord(name: "Thomas", time: "\(appState.pickUpDay.short) · \(Self.minutes(appState.pickUpChoice, -2))")
                conditionRecord(name: "James", time: "\(appState.pickUpDay.short) · \(Self.minutes(appState.pickUpChoice, 1))")
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Deposit · \(Scenario.depositAmount) · \(appState.depositStatusText)").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("Held securely by Borro until the steamer is successfully returned.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        } actions: {
            PrimaryButton(title: "View Timeline", identifier: "viewTimelineButton") { router.go(.s6_20) }
        }
    }

    /// Record times a couple of minutes either side of the agreed pick-up (Figma: 7:28 pm and 7:31 pm).
    private static func minutes(_ time: TimeOfDay?, _ offset: Int) -> String {
        let base = time ?? Scenario.defaultPickUpTime
        let total = (base.hour * 60 + base.minute + offset + 24 * 60) % (24 * 60)
        return TimeOfDay(hour: total / 60, minute: total % 60).label
    }

    private func conditionRecord(name: String, time: String) -> some View {
        VStack(alignment: .leading, spacing: Space.x6) {
            HStack {
                Text("\(name) · ✓ Submitted").font(.b(.s12)).foregroundStyle(Color.ink)
                Spacer()
                Text(time).font(.r(.s10)).foregroundStyle(Color.inkSecondary)
            }
            HStack(spacing: Space.x8) {
                PhotoView(photo: .steamerShirt).frame(height: Size.recordPhoto).clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                PhotoView(photo: .steamerShirt).frame(height: Size.recordPhoto).clipShape(RoundedRectangle(cornerRadius: Radius.r8))
            }
            Text("FRONT ✓ · BACK ✓").font(.r(.s10)).foregroundStyle(Color.inkSecondary)
        }
    }
}

#Preview {
    PreviewHost(.s6_19)
}
