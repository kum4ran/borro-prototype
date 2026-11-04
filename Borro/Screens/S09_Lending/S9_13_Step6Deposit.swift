import SwiftUI

/// Figma frame "9.13 Thomas · Step 6 deposit" (node 708:1421).
/// CONFLICT: Figma shows "$ 50" in the amount field while $10 is selected; the deposit is $10.
struct S9_13_Step6DepositView: View {
    var body: some View {
        ListingStepPage(step: 6, caption: "Set Deposit Fee", heading: "Safety deposit",
                        subheading: "Want extra peace of mind? Ask borrowers to put down a refundable deposit.",
                        backTo: .s9_12, action: "Continue with \(Scenario.depositAmount) deposit", next: .s9_14) {
            option("No deposit", "Get requests faster", selected: false)
            option("Ask for a deposit", "Refunded in full after a safe return", selected: true)
            Text("Deposit amount (SGD)").font(.b(.s13)).foregroundStyle(Color.ink)
            HStack {
                Text("$").font(.b(.s18))
                Text("10").font(.b(.s22))
                Spacer()
                Text("SGD").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .foregroundStyle(Color.ink)
            .padding(.horizontal, Space.x12)
            .frame(minHeight: Size.inputHeight)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.card))
            .overlay(RoundedRectangle(cornerRadius: Radius.card).strokeBorder(Color.brand, lineWidth: Size.buttonStroke))
            HStack(spacing: Space.x8) {
                ForEach(["$20", "$30", Scenario.depositAmount, "$100", "Other"], id: \.self) {
                    FilterPill(label: $0, selected: $0 == Scenario.depositAmount)
                }
            }
            Text("Tap a quick amount or type your own. Similar items usually ask for $30 to $60.")
                .font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Held by Borro, refunded after a safe return").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("Borrowers pay Borro, not you. You only get paid out if there’s damage.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        }
    }

    private func option(_ title: String, _ detail: String, selected: Bool) -> some View {
        HStack(spacing: Space.x12) {
            Circle().strokeBorder(selected ? Color.brand : Color.strokeMist, lineWidth: Size.buttonStroke)
                .overlay(Circle().fill(selected ? Color.brand : .clear).padding(Space.x4))
                .frame(width: Size.iconSmall, height: Size.iconSmall)
            VStack(alignment: .leading, spacing: Space.x2) {
                Text(title).font(.b(.s14)).foregroundStyle(Color.ink)
                Text(detail).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            Spacer()
        }
        .padding(Space.x12)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.card))
        .overlay(RoundedRectangle(cornerRadius: Radius.card).strokeBorder(selected ? Color.brand : Color.stroke, lineWidth: Size.buttonStroke))
    }
}

#Preview {
    PreviewHost(.s9_13)
}
