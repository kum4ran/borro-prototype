import SwiftUI

// Lending agreement — Figma section 5 · Lending agreement
// Artboards: 5.1 691-5698 · 5.2 691-5763 · 5.3 691-5836 · 5.4 691-5930
//            5.5 691-6006 · 5.6 691-6074
//
// This file also carries the small pieces of chrome shared with HandoverFlow
// (same visual language: bottom navigation, pill buttons, bottom-sheet surface).

// MARK: - Palette additions from the section 5 / 6 specs
//
// Only values that appear in the Figma spec and are not already in `BColor`.

enum BHandoverTone {
    static let greenTint    = Color(hex: 0xE8F4EC)   // deposit / photo notices
    static let greenStroke  = Color(hex: 0xB7D9C5)   // deposit receipt border
    static let greenText    = Color(hex: 0x1E8E5A)   // success check marks
    static let red          = Color(hex: 0xD64545)   // code error text / border
    static let redText      = Color(hex: 0xE07474)   // code error digits
    static let sheetGrey    = Color(hex: 0xF3F3F3)   // light sheet (edit name)
    static let muted        = Color(hex: 0x5C5C5C)   // helper text under codes
    static let control      = Color(hex: 0xEDF0EC)   // disabled action / pills
    static let scrim        = Color(hex: 0x14231C)   // sheet scrim (33%)
    static let handle       = Color(hex: 0xB8C4BB)   // drag handle
}

// MARK: - Bottom navigation inside a flow
//
// Flow screens are pushed on top of the tab roots, but every artboard in
// sections 5 / 6 still draws the 78pt navigation bar, so the flow renders it.

struct BHandoverNavBar: View {
    var active: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(BColor.stroke)
                .frame(height: 1)
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    VStack(spacing: 3) {
                        Image(systemName: tab.safeIcon(selected: tab == active))
                            .font(.system(size: 19, weight: .regular))
                            .frame(height: 21)
                        Text(tab.rawValue)
                            .font(tab == active ? BFont.microBold : BFont.microMedium)
                    }
                    .foregroundStyle(tab == active ? BColor.brand : BColor.inkSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 9)
            Spacer(minLength: 0)
        }
        .frame(height: 78)
        .background(BColor.surface)
    }
}

// MARK: - Pill actions (primary / outline / disabled)

struct BHandoverActionStyle: ButtonStyle {
    enum Kind { case primary, outline, disabled }

    var kind: Kind = .primary
    var height: CGFloat = 48

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BFont.bold(14))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                if kind == .outline {
                    Capsule().stroke(BColor.brand, lineWidth: 1.2)
                }
            }
            .opacity(configuration.isPressed ? 0.9 : 1)
    }

    private var foreground: Color {
        switch kind {
        case .primary: return .white
        case .outline: return BColor.brand
        case .disabled: return BColor.inkSecondary
        }
    }

    private var background: Color {
        switch kind {
        case .primary: return BColor.brand
        case .outline: return BColor.surface
        case .disabled: return BHandoverTone.control
        }
    }
}

// MARK: - Bottom sheet chrome

struct BHandoverSheetSurface<Content: View>: View {
    var background: Color = BColor.surface
    var horizontalPadding: CGFloat = 20
    var topPadding: CGFloat = 20
    var bottomPadding: CGFloat = 20
    var spacing: CGFloat = 15
    var handleTop: CGFloat = 9
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(BHandoverTone.handle)
                .frame(width: 38, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, handleTop)

            VStack(alignment: .leading, spacing: spacing) {
                content
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, max(0, topPadding - handleTop - 4))
            .padding(.bottom, bottomPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .background(background)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: BRadius.sheet,
                topTrailingRadius: BRadius.sheet
            )
        )
    }
}

struct BHandoverSheetScrim: View {
    var onTap: (() -> Void)?

    var body: some View {
        BHandoverTone.scrim
            .opacity(0.33)
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture { onTap?() }
    }
}

// MARK: - Agreement state machine

enum AgreementSheet {
    case careNote
    case depositInfo
}

struct AgreementFlow: View {
    @EnvironmentObject private var router: AppRouter

    var startScreen: String? = nil

    @State private var stack: [String] = []
    @State private var sheet: AgreementSheet? = nil

    private let entry = "691-5698"

    var body: some View {
        ZStack {
            screen(for: baseSlug(current))
            if let sheet {
                AgreementSheetOverlay(sheet: sheet, onDismiss: { self.sheet = nil })
            }
        }
        .bBackground()
        .onAppear {
            if stack.isEmpty {
                let slug = startScreen ?? entry
                stack = [slug]
                sheet = sheetForSlug(slug)
            } else {
                sheet = sheetForSlug(current)
            }
        }
        .onChange(of: current) { _, newValue in
            sheet = sheetForSlug(newValue)
        }
    }

    private var current: String { stack.last ?? entry }

    private func go(_ slug: String) {
        withAnimation(.easeOut(duration: 0.2)) { stack.append(slug) }
    }

    private func back() {
        if stack.count > 1 {
            withAnimation(.easeOut(duration: 0.2)) { _ = stack.popLast() }
        } else {
            router.pop()
        }
    }

    private func baseSlug(_ slug: String) -> String {
        switch slug {
        case "691-5836", "691-5930": return "691-5763"
        default: return slug
        }
    }

    private func sheetForSlug(_ slug: String) -> AgreementSheet? {
        switch slug {
        case "691-5836": return .careNote
        case "691-5930": return .depositInfo
        default: return nil
        }
    }

    @ViewBuilder
    private func screen(for slug: String) -> some View {
        switch slug {
        case "691-5763", "691-6006":
            AgreementBorrowerScreen(
                paid: slug == "691-6006",
                startChecked: slug == "691-6006",
                back: back,
                openCareNote: { withAnimation(.easeOut(duration: 0.2)) { sheet = .careNote } },
                openDepositInfo: { withAnimation(.easeOut(duration: 0.2)) { sheet = .depositInfo } },
                pay: { go("691-6006") },
                submit: { go("691-6074") },
                cancel: { back() }
            )
        case "691-6074":
            AgreementSubmittedScreen(
                back: back,
                goToHandover: { router.push(.flow(.handover, screen: nil)) }
            )
        default:
            AgreementLenderScreen(
                back: back,
                edit: { go("691-5763") },
                chat: { router.push(.flow(.schedule, screen: nil)) },
                openDepositInfo: { withAnimation(.easeOut(duration: 0.2)) { sheet = .depositInfo } }
            )
        }
    }
}

// MARK: - 5.1 Thomas · Agreement sent (lender view)

private struct AgreementLenderScreen: View {
    var back: () -> Void
    var edit: () -> Void
    var chat: () -> Void
    var openDepositInfo: () -> Void

    private let terms = "Borrowers must return the item at the agreed time, in the recorded condition and with all accessories. Both members must record photos at pickup and return. Do not share one-time codes before meeting in person. Confirmed damage is assessed fairly using both members’ photo records. Any repair balance requires separate payment consent."

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Final Agreement",
                subtitle: "James · Borrower / Thomas · Lender",
                showsBack: true,
                backAction: back
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    summaryCard
                    depositTitleRow
                    paymentReceipt
                    careInstructionsCard
                    termsCard
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            actions
            BHandoverNavBar(active: .lend)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Garment Steamer")
                .font(BFont.bold(17))
                .foregroundStyle(BColor.ink)
            Text("18 Oct 2026, 7:30 pm → 19 Oct, 11:00 pm")
                .font(BFont.regular(12))
                .foregroundStyle(BColor.ink)
            Text("⌖ Block A Security Desk")
                .font(BFont.regular(12))
                .foregroundStyle(BColor.inkSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }

    private var depositTitleRow: some View {
        HStack(spacing: 8) {
            Text("Safety Deposit: $10")
                .font(BFont.bold(18))
                .foregroundStyle(BColor.ink)
            Spacer(minLength: 0)
            Button(action: openDepositInfo) {
                Image(systemName: "info.circle")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(BColor.inkSecondary)
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 24)
    }

    private var paymentReceipt: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(BHandoverTone.greenText)
                    .frame(width: 20, height: 20)
                Text("Deposit paid · $10 via PayNow")
                    .font(BFont.bold(16))
                    .foregroundStyle(.black)
            }
            Text("Ref #BR-20481")
                .font(BFont.bold(14))
                .foregroundStyle(.black)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BHandoverTone.greenTint)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BHandoverTone.greenStroke, lineWidth: 1)
        }
    }

    private var careInstructionsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Thomas's care instructions")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            Text("1. Use clean water only. 2. Let it cool before packing and empty the tank. 3. Return the heat-resistant mitt.")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    private var termsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Terms & Conditions")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            TermsText(text: terms)
                .frame(height: 126)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    private var actions: some View {
        VStack(spacing: 8) {
            Button(action: edit) {
                Text("Edit Agreement")
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))

            Button(action: chat) {
                Text("Chat with James")
            }
            .buttonStyle(BHandoverActionStyle(kind: .outline))
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .background(BColor.bg)
    }
}

// MARK: - 5.2 / 5.5 Final Agreement (borrower view)

private struct AgreementBorrowerScreen: View {
    var paid: Bool
    var startChecked: Bool
    var back: () -> Void
    var openCareNote: () -> Void
    var openDepositInfo: () -> Void
    var pay: () -> Void
    var submit: () -> Void
    var cancel: () -> Void

    @State private var agreed: Bool = false

    private let terms = "Borrowers must return the item at the agreed time, in the recorded condition and with all accessories. Both members must record photos at pickup and return. Do not share one-time codes before meeting in person. Confirmed damage is assessed fairly using both members’ photo records. Any repair balance requires separate payment consent."

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Final Agreement",
                subtitle: "James & Thomas · 18–19 Oct 2026",
                showsBack: true,
                backAction: back
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    summaryCard
                    depositSection
                    instructionsCard
                    termsCard
                    consentRow
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            actions
            BHandoverNavBar(active: .borro)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear { agreed = startChecked }
        .onChange(of: startChecked) { _, newValue in agreed = newValue }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Garment Steamer")
                .font(BFont.bold(19))
                .foregroundStyle(BColor.ink)
            Text("18 Oct, 7:30 pm → 19 Oct, 11:00 pm")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.ink)
            Text("⌖ Block A Security Desk")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow(1)
    }

    private var depositSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Safety Deposit: $10")
                    .font(BFont.bold(18))
                    .foregroundStyle(BColor.ink)
                Spacer(minLength: 0)
                Button(action: openDepositInfo) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(BColor.inkSecondary)
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.plain)
            }
            .frame(height: 24)

            if paid {
                paymentReceipt
            } else {
                paymentChoices
            }

            Text("Selecting a payment method authorises your $10 deposit.")
                .font(BFont.regular(11))
                .foregroundStyle(BColor.inkSecondary)
        }
    }

    private var paymentChoices: some View {
        HStack(spacing: 10) {
            Button(action: pay) {
                ZStack {
                    if let image = BPhoto.payNow.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 34)
                    } else {
                        Text("PayNow · $10")
                            .font(BFont.bold(15))
                            .foregroundStyle(BColor.brand)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(BColor.surface)
                .clipShape(Capsule())
                .overlay { Capsule().stroke(BColor.brand, lineWidth: 1.2) }
            }
            .buttonStyle(.plain)

            Button(action: pay) {
                HStack(spacing: 2) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 19, weight: .regular))
                    Text("Pay")
                        .font(.system(size: 21, weight: .regular))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(BColor.surface)
                .clipShape(Capsule())
                .overlay { Capsule().stroke(BColor.brand, lineWidth: 1.2) }
            }
            .buttonStyle(.plain)
        }
        .frame(height: 48)
    }

    private var paymentReceipt: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(BHandoverTone.greenText)
                    .frame(width: 20, height: 20)
                Text("Deposit paid · $10 via PayNow")
                    .font(BFont.bold(16))
                    .foregroundStyle(.black)
            }
            Text("Ref #BR-20481")
                .font(BFont.bold(14))
                .foregroundStyle(.black)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BHandoverTone.greenTint)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BHandoverTone.greenStroke, lineWidth: 1)
        }
    }

    private var instructionsCard: some View {
        Button(action: openCareNote) {
            HStack(spacing: 8) {
                Text("Instructions From Lender ")
                    .font(BFont.bold(11))
                    .foregroundStyle(BColor.ink)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 14)
            .frame(height: 45)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                    .stroke(BColor.stroke, lineWidth: 0.7)
            }
        }
        .buttonStyle(.plain)
    }

    private var termsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Terms & Conditions")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            TermsText(text: terms)
                .frame(height: 126)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    private var consentRow: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeOut(duration: 0.12)) { agreed.toggle() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(agreed ? BColor.brand : BColor.surface)
                        .frame(width: 23, height: 23)
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(agreed ? BColor.brand : BHandoverTone.handle, lineWidth: agreed ? 0 : 1)
                        .frame(width: 23, height: 23)
                    if agreed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            Text("I agree to the Terms & Conditions and the lender's care instructions.")
                .font(BFont.regular(14))
                .foregroundStyle(BColor.ink)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minHeight: 44)
    }

    private var actions: some View {
        VStack(spacing: 8) {
            Button(action: submit) {
                Text("Submit Agreement")
            }
            .buttonStyle(BHandoverActionStyle(kind: paid && agreed ? .primary : .disabled))
            .disabled(!(paid && agreed))

            Button(action: cancel) {
                Text("Cancel")
            }
            .buttonStyle(BHandoverActionStyle(kind: .outline))
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .background(BColor.bg)
    }
}

// MARK: - 5.6 Agreement submitted

private struct AgreementSubmittedScreen: View {
    var back: () -> Void
    var goToHandover: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Agreement submitted",
                subtitle: "BR-20481 · 18–19 Oct 2026",
                showsBack: true,
                backAction: back
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    successHeading
                    summaryCard
                    depositNotice
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            Button(action: goToHandover) {
                Text("Go to handover")
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)

            BHandoverNavBar(active: .borro)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private var successHeading: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(BHandoverTone.greenTint).frame(width: 74, height: 74)
                Image(systemName: "checkmark")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(BColor.brand)
            }
            Text("You're all agreed")
                .font(BFont.bold(24))
                .foregroundStyle(BColor.ink)
            Text("Your agreement is saved. Meet in person to confirm the handover.")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(1.5)
                .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Garment Steamer")
                .font(BFont.bold(18))
                .foregroundStyle(BColor.ink)
            detailRow("Borrower  ·  James", tint: BColor.inkSecondary)
            detailRow("Lender  ·  Thomas", tint: BColor.inkSecondary)
            detailRow("Pickup  ·  18 Oct · 7:30 pm", tint: BColor.ink)
            detailRow("Return  ·  19 Oct · 11:00 pm", tint: BColor.ink)
            Text("⌖ Block A Security Desk")
                .font(BFont.regular(14))
                .foregroundStyle(BColor.ink)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow(1)
    }

    private func detailRow(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(BFont.regular(13))
            .foregroundStyle(tint)
            .frame(height: 24, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var depositNotice: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("✓ Deposit paid · $10 SGD")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            Text("PayNow · Ref #BR-20481 · Held securely by Borro")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BHandoverTone.greenTint)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }
}

// MARK: - Sheets

private struct AgreementSheetOverlay: View {
    var sheet: AgreementSheet
    var onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(0.08)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onDismiss() }
            sheetSurface
        }
    }

    @ViewBuilder
    private var sheetSurface: some View {
        switch sheet {
        case .careNote:
            BHandoverSheetSurface(
                horizontalPadding: 22,
                topPadding: 32,
                bottomPadding: 30,
                spacing: 16,
                handleTop: 12
            ) {
                careNote
            }
            .ignoresSafeArea(.container, edges: .bottom)
        case .depositInfo:
            BHandoverSheetSurface(
                horizontalPadding: 22,
                topPadding: 32,
                bottomPadding: 30,
                spacing: 16,
                handleTop: 12
            ) {
                depositInfo
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private var careNote: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Thomas's care instructions")
                    .font(BFont.bold(21))
                    .foregroundStyle(BColor.ink)
                Text("Garment Steamer")
                    .font(BFont.regular(12))
                    .foregroundStyle(BColor.inkSecondary)
            }

            Text("Use clean water only and empty the tank after use. Let it cool before packing. Do not steam over buttons or zips. Return with the heat-resistant mitt.")
                .font(BFont.regular(15))
                .foregroundStyle(BColor.ink)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 143, alignment: .topLeading)
                .background(BColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                        .stroke(BColor.stroke, lineWidth: 0.7)
                }

            Rectangle()
                .fill(BColor.stroke)
                .frame(height: 1)

            HStack(spacing: 10) {
                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Copy")
                    }
                }
                .buttonStyle(BHandoverActionStyle(kind: .outline, height: 44))

                Button(action: {}) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.to.line")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Download")
                    }
                }
                .buttonStyle(BHandoverActionStyle(kind: .primary, height: 44))
            }
        }
    }

    private var depositInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Held securely by Borro")
                .font(BFont.bold(21))
                .foregroundStyle(BColor.ink)
            Text("Held securely by Borro. Refunded within 1 working day after a successful return. Fully refunded if the borrowing is cancelled or the lender doesn't show up. If damage is confirmed, it goes toward the repair quote.")
                .font(BFont.regular(14))
                .foregroundStyle(BColor.inkSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Shared bits

/// The scrollable Terms & Conditions body, with the static scroll thumb drawn
/// on the right exactly as in Figma.
private struct TermsText: View {
    var text: String

    var body: some View {
        ScrollView(showsIndicators: false) {
            Text(text)
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .lineSpacing(1.8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(hex: 0xD9D9D9))
                .frame(width: 6, height: 50)
        }
    }
}
