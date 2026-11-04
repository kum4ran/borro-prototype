import SwiftUI

/// Figma frame "6.10 Thomas · Drop-off saved · share code" (node 703:2035).
struct S6_10_DropOffSavedShareCodeView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Drop-off saved", subtitle: "\(appState.meetUpPlace) · \(Scenario.reference)")
        } content: {
            ResultSeal(icon: .check, fill: .successMint, tint: .brand)
            VStack(spacing: Space.x8) {
                Text("Before photos saved").font(.b(.s22)).foregroundStyle(Color.ink)
                Text("Ask James to enter your lender code on his phone to collect the steamer.")
                    .font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            AgreedRowsCard()
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("✓ Before photos recorded").font(.b(.s13)).foregroundStyle(Color.successDeep)
                Text("Both of you can see them in the timeline.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        } actions: {
            PrimaryButton(title: "Hand over to James", identifier: "handOverButton") { router.go(.s6_10a) }
        }
    }
}

/// "Garment Steamer / Borrower · James / … / ⌖ place" card (5.6, 6.10).
struct AgreedRowsCard: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x10) {
            Text("Garment Steamer").font(.b(.s16)).foregroundStyle(Color.ink)
            DotRow(label: "Borrower", value: MockData.james.name)
            DotRow(label: "Lender", value: MockData.thomas.name)
            DotRow(label: "Pickup", value: appState.pickUpShort)
            DotRow(label: "Return", value: appState.returnShort)
            Text("⌖ \(appState.meetUpPlace)").font(.r(.s13)).foregroundStyle(Color.ink)
        }
        .cardStyle()
    }
}

#Preview {
    PreviewHost(.s6_10)
}
