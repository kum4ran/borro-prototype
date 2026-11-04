import SwiftUI

/// Figma frame "10.9 Both · Repair balance paid" (node 708:2371).
struct S10_9_RepairBalancePaidView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Post-Borro Review", subtitle: "Garment Steamer · Damage case", backTo: .s10_8)
        } content: {
            IconView(icon: .checkCircle, size: Size.resultIcon).foregroundStyle(Color.brand)
                .frame(maxWidth: .infinity).padding(.top, Space.x24)
            VStack(spacing: Space.x8) {
                Text("All settled.").font(.b(.s29)).foregroundStyle(Color.ink)
                Text("Your \(MockData.repairBalance) repair balance is paid.").font(.r(.s15)).foregroundStyle(Color.ink)
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("✓ Payment successful – \(MockData.repairBalance) via PayNow").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("Ref #\(Scenario.reference)-R · 21 Oct 2026").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Outcome ✓ · Case closed").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("Accidental – both parties agree on compensation.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        } actions: {
            PrimaryButton(title: "View completed borrowing") { router.go(.s7_6) }
        }
    }
}

#Preview {
    PreviewHost(.s10_9)
}
