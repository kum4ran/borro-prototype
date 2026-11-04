import SwiftUI

/// Figma frame "10.7 Both · Timeline · repair" (node 708:2234).
/// CONFLICT: Figma shows Thomas as "★ 4.7 · 47 reviews" here; everywhere else he is 5.0 (10 reviews).
struct S10_7_TimelineRepairView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    private let thomas = MockData.thomas

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Timeline", subtitle: "Garment Steamer · \(Scenario.reference)")
        } content: {
            StageBar(current: AppState.TimelineStage.returned.rawValue)
            HStack(spacing: Space.x12) {
                PhotoView(photo: .steamerDesk).frame(width: Size.thumb, height: Size.thumbSquare)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
                Text("Garment Steamer\nCompleted").font(.b(.s18)).foregroundStyle(Color.ink)
                Spacer()
            }
            .cardStyle(padding: Space.x8, shadow: false)
            PersonStrip(user: thomas, line: "★ \(thomas.rating) · \(thomas.reviewCount) reviews")
            VStack(alignment: .leading, spacing: Space.x6) {
                DotRow(label: "Pickup", value: "18 Oct · \(appState.pickUpTime)")
                DotRow(label: "Return", value: "19 Oct · \(appState.returnTime)")
                Text("⌖ \(Scenario.meetUpPlace)").font(.r(.s13)).foregroundStyle(Color.ink)
            }
            .cardStyle(shadow: false)
            SecondaryButton(title: "View Agreement") { router.go(.s5_2) }
            SecondaryButton(title: "Before / After · View condition photos") {}
            Text("Deposit Status · Used for repair").font(.b(.s13)).foregroundStyle(Color.ink)
                .panel(.successFill, padding: Space.x10, radius: Radius.r8)
            LinkButton(title: "View damage outcome →") { router.go(.s10_8) }
                .accessibilityIdentifier("damageOutcomeLink")
        } actions: {
            PrimaryButton(title: "Chat with Thomas") { router.go(.s4_9) }
        }
    }
}

#Preview {
    PreviewHost(.s10_7)
}
