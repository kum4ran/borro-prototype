import SwiftUI
import CoreImage.CIFilterBuiltins

/// Real QR code from Core Image (CIQRCodeGenerator).
struct QRCodeView: View {
    let payload: String

    var body: some View {
        if let image = Self.make(payload) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .accessibilityLabel("PayNow QR code")
        }
    }

    static func make(_ payload: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage,
              let cg = CIContext().createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}

/// Item, dates and place at the top of the agreement frames.
struct AgreementItemCard: View {
    let dates: String

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x6) {
            Text("Garment Steamer").font(.b(.s18)).foregroundStyle(Color.ink)
            Text(dates).font(.r(.s13)).foregroundStyle(Color.ink)
            Text("⌖ \(Scenario.meetUpPlace)").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
        }
        .cardStyle(padding: Space.x14)
    }
}

/// Green "Deposit paid · $10 via PayNow" panel, or the amber "Awaiting deposit" state.
struct DepositPaidPanel: View {
    let paid: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x6) {
            HStack(spacing: Space.x8) {
                IconView(icon: paid ? .checkCircle : .clock, size: Size.icon)
                Text(paid ? "Deposit paid · \(Scenario.depositAmount) via PayNow" : "Awaiting deposit · \(Scenario.depositAmount)")
                    .font(.b(.s14))
            }
            .foregroundStyle(paid ? Color.successDeep : Color.pendingInk)
            Text("Ref #\(Scenario.reference)").font(.b(.s12)).foregroundStyle(Color.ink)
        }
        .padding(Space.x12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(paid ? Color.successFill : Color.pendingFill, in: RoundedRectangle(cornerRadius: Radius.card))
        .overlay(RoundedRectangle(cornerRadius: Radius.card).strokeBorder(paid ? Color.success.opacity(0.3) : .clear))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("depositPanel")
    }
}

/// "Terms & Conditions" card: the title opens 5.2e, the chevron expands it (Figma CHANGE_TO variant).
struct TermsCard: View {
    let onOpen: () -> Void
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x8) {
            HStack {
                Button(action: onOpen) {
                    Text("Terms & Conditions").font(.b(.s13)).underline().foregroundStyle(Color.brand)
                        .frame(minHeight: Size.hitTarget)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("termsLink")
                Spacer()
                IconButton(icon: .chevronDown, size: Size.iconSmall, label: expanded ? "Collapse terms" : "Expand terms") {
                    withAnimation { expanded.toggle() }
                }
                .rotationEffect(.degrees(expanded ? 180 : 0))
                .padding(.trailing, -Space.x12)
            }
            if expanded {
                ForEach(TermsContent.sections, id: \.title) { section in
                    Text(section.title).font(.s(.s12)).foregroundStyle(Color.ink)
                }
            }
        }
        .padding(.horizontal, Space.x10)
        .padding(.vertical, -Space.x4)
        .cardStyle(padding: Space.x4, shadow: false)
    }
}

/// Square checkbox row.
struct CheckboxRow: View {
    let text: String
    let checked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: Space.x12) {
                RoundedRectangle(cornerRadius: Radius.r4)
                    .fill(checked ? Color.brand : Color.surface)
                    .overlay(RoundedRectangle(cornerRadius: Radius.r4).strokeBorder(checked ? Color.brand : Color.strokeMist, lineWidth: Size.buttonStroke))
                    .overlay { if checked { IconView(icon: .check, size: Size.iconTiny).foregroundStyle(Color.surface) } }
                    .frame(width: Size.checkbox, height: Size.checkbox)
                Text(text).font(.r(.s14)).foregroundStyle(Color.ink).multilineTextAlignment(.leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(checked ? .isSelected : [])
        .accessibilityIdentifier("agreeCheckbox")
    }
}

enum TermsContent {
    struct Section { let title: String; let body: String }

    static let intro = "These terms apply to every borrowing on Borro, including James borrowing Thomas's Garment Steamer (\(Scenario.borrowDatesShort)). Submitting the Final Agreement means both members accept them."

    static let sections = [
        Section(title: "1. Using the item", body: "Use the item only as described in the listing, and follow the lender's care instructions in the agreement."),
        // CONFLICT: Figma says "19 Oct, 10:00 am"; the scenario return time wins.
        Section(title: "2. Returning on time", body: "Return the item at the agreed place and time (19 Oct, \(Scenario.returnTime), \(Scenario.meetUpPlace)) with all accessories, such as the heat-resistant mitt. Late returns lower the borrower's credibility score."),
        Section(title: "3. Photos and handover codes", body: "Both members photograph the item at pick-up and at return. Share one-time codes only when you meet in person. Codes refresh every few minutes."),
        Section(title: "4. Safety deposit", body: "The \(Scenario.depositAmount) deposit is held by Borro. It is refunded within 1 working day after a successful return, or in full if the borrowing is cancelled or the lender does not show up."),
        Section(title: "5. Damage and repairs", body: "Report damage in the app as soon as it happens. Borro compares both members' photos. If damage is confirmed, the deposit goes toward the repair quote, and any remaining balance needs the borrower's separate payment consent."),
        Section(title: "6. Cancellations", body: "Either member can cancel before the handover. The other member is told why, and the deposit is returned."),
        Section(title: "7. Disputes", body: "If members cannot agree, Borro reviews the photo records, chat and agreement, and shares a decision within 3 working days."),
    ]

    static let updated = "Last updated 1 Oct 2026"

    static let careNoteShort = "1. Use clean water only. 2. Let it cool before packing and empty the tank. 3. Return the heat-resistant mitt."
    static let careNote = "1. Use clean water only and empty the tank after use. Let it cool before packing. Do not steam over buttons or zips. Return with the heat-resistant mitt."
    static let depositInfo = "Held securely by Borro. Refunded within 1 working day after a successful return. Fully refunded if the borrowing is cancelled or the lender doesn't show up. If damage is confirmed, it goes toward the repair quote."
}
