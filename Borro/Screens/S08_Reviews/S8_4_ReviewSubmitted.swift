import SwiftUI

/// Figma frame "8.4 James · Review submitted" (node 691:6916).
/// The push banner is the simulated jump to Thomas (8.5); Figma's button keeps its 8.8 link.
struct S8_4_ReviewSubmittedView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ReviewSubmittedPage(person: "Thomas", stars: appState.thomasCategoryStars,
                            action: "View deposit refund", actionID: "viewDepositRefundButton") {
            appState.depositRefunded()
            router.go(.s8_8)
        } extra: {
            TapArea(accessibilityLabel: "Thomas’s phone: How was James with your steamer?") { router.go(.s8_5) } label: {
                HStack(spacing: Space.x10) {
                    BorroAppIcon()
                    VStack(alignment: .leading, spacing: Space.x2) {
                        Text("Meanwhile, on Thomas’s phone").font(.b(.s12)).foregroundStyle(Color.ink)
                        Text("How was James with your steamer?").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                    }
                    Spacer()
                    IconView(icon: .chevronRight, size: Size.iconSmall).foregroundStyle(Color.ink)
                }
                .panel(.brandMist)
            }
            .accessibilityIdentifier("thomasPushBanner")
        }
    }
}

#Preview {
    PreviewHost(.s8_4)
}
