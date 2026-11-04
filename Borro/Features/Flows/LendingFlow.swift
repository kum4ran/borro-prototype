import SwiftUI

// MARK: - Section 9 · My Lending and List an Item
//
// Sections (Figma node 708:169), all reachable from the flow's entry screen:
//   708-170  9.1  My Lending · Active
//   708-275  9.2  My Lending · Sort / Filter (sheet over active list)
//   708-414  9.3  My Lending · Past loans
//   708-518  9.4  Past loans · Sort / Filter (sheet)
//   708-648  9.5  Manage listing menu (sheet)
//   708-775  9.6  Paused listing (sheet)
//   708-889  9.7  Delete confirmation (dialog)
//   708-1002 9.8  Step 1 · photos
//   708-1065 9.9  Step 2 · details
//   708-1135 9.10 Step 3 · pick-up
//   708-1214 9.11 Step 4 · availability
//   708-1363 9.12 Step 5 · period
//   708-1421 9.13 Step 6 · deposit
//   708-1510 9.14 Step 7 · care
//   708-1574 9.15 Step 8 · terms
//   708-1634 9.16 Listing preview
//   708-1691 9.17 Steamer is live
//
// The eight-step wizard is one screen driven by `current`; the sort/filter
// panels, the manage menu and the paused panel are bottom sheets; the delete
// confirmation is a centred dialog.

// MARK: - Figma-spec colours (values read from design/figma/spec/708-169.md)

private enum LS {
    static let amberInk   = Color(hex: 0x92600A)
    static let amberSoft  = Color(hex: 0xFFF3D9)
    static let loanInk    = Color(hex: 0x2341DD)
    static let loanSoft   = Color(hex: 0xEBEEFC)
    static let dangerInk  = Color(hex: 0xD64545)
    static let dangerSoft = Color(hex: 0xFDECE9)
    static let successInk = Color(hex: 0x1E8E5A)
    static let successSoft = Color(hex: 0xE8F4EC)
    static let pausedInk  = Color(hex: 0x68766E)
    static let pausedSoft = Color(hex: 0xEDF0EC)
    static let handle     = Color(hex: 0xB8C4BB)
    static let sheetHandle = Color(hex: 0xB9BCBF)
    static let optionalBg = Color(hex: 0xE5E8E3)
    static let optionalInk = Color(hex: 0x4A514D)
    static let scrim      = Color(hex: 0x14231C)
    static let mapBg      = Color(hex: 0xE8EEE4)
    static let mapBlockA  = Color(hex: 0xD8E1D3)
    static let mapBlockB  = Color(hex: 0xD5DFCF)
    static let activeGreen = Color(hex: 0x34C759)
    static let sheetBodyInk = Color(hex: 0x68766E)
}

// MARK: - Listing fixtures (section 9 is a Thomas side-branch)

private struct LActiveListing: Identifiable {
    let id: String
    let title: String
    let photo: BPhoto
    let status: String
    let statusInk: Color
    let statusBg: Color
    let detail: String
}

private struct LPastListing: Identifiable {
    let id: String
    let title: String
    let photo: BPhoto
    let avatar: BPhoto
    let detail: String
    let status: String
    let statusInk: Color
    let statusBg: Color
}

private enum LData {
    static let steamer = LActiveListing(
        id: "steamer", title: "Garment Steamer", photo: .steamer,
        status: "Pending", statusInk: LS.amberInk, statusBg: LS.amberSoft,
        detail: "James requested 18–19 Oct 2026 · Awaiting your reply")
    static let bottle = LActiveListing(
        id: "bottle", title: "Water Bottle", photo: .bottle,
        status: "Handover pending", statusInk: LS.amberInk, statusBg: LS.amberSoft,
        detail: "Handover to Thomas · Fri, 3:00 PM · Bencoolen St")
    static let speaker = LActiveListing(
        id: "speaker", title: "Speaker", photo: BPhoto(key: "photo_c8ecf538e8"),
        status: "On loan", statusInk: LS.loanInk, statusBg: LS.loanSoft,
        detail: "With Maria · Due 2 Nov")
    static let camera = LActiveListing(
        id: "camera", title: "Camera", photo: .camera,
        status: "Overdue", statusInk: LS.dangerInk, statusBg: LS.dangerSoft,
        detail: "With John · Due 28 Oct")
    static let pausedBottle = LActiveListing(
        id: "bottle", title: "Water Bottle", photo: .bottle,
        status: "Paused", statusInk: LS.pausedInk, statusBg: LS.pausedSoft,
        detail: "Hidden from discovery")

    /// 9.1 order.
    static let active: [LActiveListing] = [steamer, bottle, speaker, camera]
    /// 9.5 / 9.6 / 9.7 order.
    static let manageOrder: [LActiveListing] = [bottle, speaker, camera, steamer]
    /// 9.6 paused state.
    static let paused: [LActiveListing] = [pausedBottle, speaker, camera, steamer]

    static let past: [LPastListing] = [
        LPastListing(id: "bottle", title: "Water Bottle", photo: .bottle, avatar: .thomas,
                     detail: "Lent to Thomas · 14–21 Oct",
                     status: "Returned", statusInk: LS.successInk, statusBg: LS.successSoft),
        LPastListing(id: "speaker", title: "Speaker", photo: BPhoto(key: "photo_c8ecf538e8"), avatar: .mei,
                     detail: "Lent to Maria · 12–19 Oct",
                     status: "Returned", statusInk: LS.successInk, statusBg: LS.successSoft),
        LPastListing(id: "camera", title: "Camera", photo: .camera, avatar: .lebron,
                     detail: "Request from John · Cancelled 17 Oct",
                     status: "Cancelled", statusInk: LS.dangerInk, statusBg: LS.dangerSoft)
    ]
}

// MARK: - Flow

struct LendingFlow: View {
    @EnvironmentObject private var router: AppRouter

    var startScreen: String? = nil
    /// The Lend tab root is hosted by AppShell, which draws the real tab bar.
    var showsBottomBar: Bool = true

    @State private var stack: [String] = []

    // Sort / filter state
    @State private var activeStatuses: Set<String> = []
    @State private var activeSort = "Due soonest"
    @State private var pastStatuses: Set<String> = ["Returned", "Cancelled"]
    @State private var pastSort = "Most recent first"

    // Manage / delete state
    @State private var manageName = "Speaker"

    // Wizard state
    @State private var borrowDays = 7
    @State private var depositChoice = 1
    @State private var depositAmount = "50"
    @State private var quickAmount = "$10"
    @State private var careInstructions = [
        "Use clean water only. Do not add fragrance.",
        "Keep the steamer upright while in use.",
        "Let it cool, empty the tank and dry it before returning."
    ]
    @State private var availableDays: Set<Int> = Set(13...27)
    @State private var termsAgreed = true

    private let wizardSteps = [
        "708-1002", "708-1065", "708-1135", "708-1214",
        "708-1363", "708-1421", "708-1510", "708-1574"
    ]

    // MARK: Body

    var body: some View {
        ZStack {
            screen
        }
        .ignoresSafeArea(edges: showsBottomBar ? Edge.Set.bottom : Edge.Set())
        .bBackground()
        .onAppear(perform: seed)
    }

    private var current: String { stack.last ?? "708-170" }

    @ViewBuilder
    private var screen: some View {
        switch current {
        case "708-275":
            sheetOver(listScreen(.active), scrim: 0.33) {
                LSortFilterSheet(
                    kind: .active,
                    statuses: $activeStatuses,
                    sort: $activeSort,
                    onClear: { activeStatuses = []; activeSort = "Due soonest" },
                    onApply: back)
            }
        case "708-518":
            sheetOver(listScreen(.past), scrim: 0.33) {
                LSortFilterSheet(
                    kind: .past,
                    statuses: $pastStatuses,
                    sort: $pastSort,
                    onClear: { pastStatuses = []; pastSort = "Most recent first" },
                    onApply: back)
            }
        case "708-648":
            sheetOver(listScreen(.activeManage), scrim: 0.40) { manageSheet }
        case "708-775":
            sheetOver(listScreen(.paused), scrim: 0.33) { pausedSheet }
        case "708-889":
            ZStack {
                listScreen(.activeManage)
                Color(hex: 0x14231C).opacity(0.40).ignoresSafeArea()
                deleteDialog
            }
        case "708-414":
            listScreen(.past)
        case "708-1002", "708-1065", "708-1135", "708-1214",
             "708-1363", "708-1421", "708-1510", "708-1574":
            wizardScreen
        case "708-1634":
            previewScreen
        case "708-1691":
            liveScreen
        default:
            listScreen(.active)
        }
    }

    private func seed() {
        guard stack.isEmpty else { return }
        if let startScreen {
            activeStatuses = startScreen == "708-275" ? ["Available"] : []
            pastStatuses = startScreen == "708-518" ? ["Returned", "Cancelled"] : []
            stack = initialStack(startScreen)
        } else {
            stack = ["708-170"]
        }
    }

    private func initialStack(_ slug: String) -> [String] {
        if let index = wizardSteps.firstIndex(of: slug) {
            return Array(wizardSteps.prefix(index + 1))
        }
        switch slug {
        case "708-1634": return wizardSteps + ["708-1634"]
        case "708-1691": return wizardSteps + ["708-1634", "708-1691"]
        case "708-275": return ["708-170", "708-275"]
        case "708-518": return ["708-414", "708-518"]
        case "708-648": return ["708-170", "708-648"]
        case "708-889": return ["708-170", "708-889"]
        default: return [slug]
        }
    }

    // MARK: Navigation

    private func go(_ slug: String) {
        withAnimation(.easeOut(duration: 0.2)) { stack.append(slug) }
    }

    private func back() {
        if stack.count > 1 {
            withAnimation(.easeOut(duration: 0.2)) { stack.removeLast() }
        } else {
            router.pop()
        }
    }

    private func selectTab(_ tab: AppTab) {
        if tab == .lend {
            if stack.count > 1 {
                withAnimation(.easeOut(duration: 0.2)) { stack = ["708-170"] }
            } else {
                router.switchTab(.lend)
            }
        } else {
            router.switchTab(tab)
        }
    }

    // MARK: Generic chrome

    @ViewBuilder
    private var bottomBar: some View {
        if showsBottomBar {
            LFlowTabBar(selected: .lend, onSelect: selectTab)
        }
    }

    private func sheetOver<Base: View, Sheet: View>(
        _ base: Base,
        scrim opacity: Double,
        @ViewBuilder sheet: () -> Sheet
    ) -> some View {
        ZStack(alignment: .bottom) {
            base
            Color(hex: 0x14231C).opacity(opacity).ignoresSafeArea()
            sheet().ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: List screens (9.1 / 9.3 / 9.6 / 9.7 backdrops)

    private enum ListVariant { case active, activeManage, paused, past }

    private var activeCards: [LActiveListing] {
        if activeStatuses == ["Available"] { return [LData.bottle] }
        return LData.active
    }

    private func listScreen(_ variant: ListVariant) -> some View {
        VStack(spacing: 0) {
            if variant == .past {
                LBackBar(title: "My Lending", titleSize: 21, onBack: back)
            } else {
                lendingTopBar
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    primaryAction("+ List an Item") { go("708-1002") }
                    requestsCard
                    listingToolbar(variant)
                    if variant == .past { pastPeriodChips }
                    listingCards(variant)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            bottomBar
        }
    }

    private var lendingTopBar: some View {
        HStack(spacing: 12) {
            LWordmark()
            Text("My Lending")
                .font(BFont.bold(25))
                .foregroundStyle(BColor.ink)
                .lineLimit(1)
            Spacer(minLength: 0)
            Button {
                router.push(.flow(.other, screen: "708-3039"))
            } label: {
                Image(systemName: "heart")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(BColor.brand)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BSpace.screen)
        .frame(height: 64)
    }

    private func primaryAction(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(BFont.bold(15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(BColor.brand)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func outlineAction(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(BFont.bold(15))
                .foregroundStyle(BColor.brand)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(BColor.surface)
                .clipShape(Capsule())
                .overlay { Capsule().stroke(BColor.brand, lineWidth: 1.2) }
        }
        .buttonStyle(.plain)
    }

    private var requestsCard: some View {
        Button {
            router.push(.flow(.lender, screen: "700-125"))
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(BColor.brand)
                Text("Borrow Requests")
                    .font(BFont.bold(16))
                    .foregroundStyle(BColor.ink)
                Spacer(minLength: 0)
                Text("3")
                    .font(BFont.bold(11))
                    .foregroundStyle(LS.amberInk)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(LS.amberSoft)
                    .clipShape(Capsule())
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BColor.ink)
            }
            .padding(.horizontal, 12)
            .frame(height: 47)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(BColor.stroke, lineWidth: 0.7)
            }
            .bShadow()
        }
        .buttonStyle(.plain)
    }

    private func listingToolbar(_ variant: ListVariant) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 18) {
                tabButton("Active", selected: variant != .past) {
                    if current != "708-170" {
                        withAnimation(.easeOut(duration: 0.2)) { stack = ["708-170"] }
                    }
                }
                tabButton("Past loans", selected: variant == .past) {
                    if current != "708-414" { go("708-414") }
                }
                tabButton("Paused", selected: false) {
                    if current != "708-775" { go("708-775") }
                }
            }
            Spacer(minLength: 0)
            Button {
                if variant == .past {
                    go("708-518")
                } else {
                    go("708-275")
                }
            } label: {
                HStack(spacing: 6) {
                    Text("Sort / Filter")
                        .font(BFont.regular(12))
                        .foregroundStyle(BColor.brand)
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(BColor.ink)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(height: 19)
    }

    private func tabButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(BFont.bold(15))
                .foregroundStyle(selected ? BColor.brand : LS.sheetBodyInk)
        }
        .buttonStyle(.plain)
    }

    private var pastPeriodChips: some View {
        HStack(spacing: 7) {
            periodChip("All time", selected: true)
            periodChip("Oct 2026", selected: false)
            periodChip("Sep 2026", selected: false)
            periodChip("Aug 2026", selected: false)
        }
    }

    private func periodChip(_ title: String, selected: Bool) -> some View {
        Text(title)
            .font(selected ? BFont.bold(11) : BFont.medium(11))
            .foregroundStyle(selected ? BColor.brand : LS.sheetBodyInk)
            .frame(width: 83, height: 30)
            .background(selected ? LS.loanSoft : BColor.surface)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(selected ? BColor.brand : BColor.stroke, lineWidth: 0.7)
            }
    }

    @ViewBuilder
    private func listingCards(_ variant: ListVariant) -> some View {
        switch variant {
        case .past:
            ForEach(LData.past) { listing in
                LPastListingCard(listing: listing) {
                    manageName = listing.title
                    go("708-648")
                }
            }
        case .active:
            ForEach(activeCards) { listing in
                LActiveListingCard(listing: listing) {
                    manageName = listing.title
                    go("708-648")
                }
            }
        case .activeManage:
            ForEach(LData.manageOrder) { listing in
                LActiveListingCard(listing: listing) {
                    manageName = listing.title
                    go("708-648")
                }
            }
        case .paused:
            ForEach(LData.paused) { listing in
                LActiveListingCard(listing: listing) {
                    manageName = listing.title
                    go("708-648")
                }
            }
        }
    }

    // MARK: 9.5 Manage listing sheet

    private var manageSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Capsule().fill(LS.handle).frame(width: 38, height: 4)
                Spacer()
            }
            Text("Manage \(manageName)")
                .font(BFont.bold(21))
                .foregroundStyle(BColor.ink)
            manageRow("pencil", "Edit Listing", enabled: true) { go("708-1002") }
            manageRow("pause", "Pause Listing", enabled: true) {
                withAnimation(.easeOut(duration: 0.2)) { stack = ["708-775"] }
            }
            manageRow("star", "Mark as Important", enabled: true) {}
            manageRow("trash", "Delete", enabled: true, tint: LS.sheetBodyInk, faded: true) {
                go("708-889")
            }
            Text("You can delete this item after it’s returned.")
                .font(BFont.regular(11))
                .foregroundStyle(LS.sheetBodyInk)
        }
        .padding(.leading, 22)
        .padding(.trailing, 22)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func manageRow(
        _ icon: String,
        _ title: String,
        enabled: Bool,
        tint: Color = BColor.ink,
        faded: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(faded ? LS.sheetBodyInk : BColor.brand)
                    .frame(width: 22, height: 22)
                Text(title)
                    .font(BFont.bold(16))
                    .foregroundStyle(tint)
                Spacer(minLength: 0)
            }
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(faded ? 0.45 : 1)
        .disabled(!enabled)
    }

    // MARK: 9.6 Paused listing sheet

    private var pausedSheet: some View {
        VStack(spacing: 12) {
            Text("Manage paused listing")
                .font(BFont.bold(20))
                .foregroundStyle(BColor.ink)
                .multilineTextAlignment(.center)
            Text("Water Bottle is hidden from discovery. Any loan already in progress continues as normal, and you can still respond to existing requests.")
                .font(BFont.regular(14))
                .foregroundStyle(LS.sheetBodyInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            primaryAction("Resume listing") {
                withAnimation(.easeOut(duration: 0.2)) { stack = ["708-170"] }
            }
            .padding(.top, 2)
            outlineAction("Archive listing") {
                withAnimation(.easeOut(duration: 0.2)) { stack = ["708-170"] }
            }
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, BSpace.xl)
        .padding(.bottom, 34)
        .frame(maxWidth: .infinity)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.sheet, style: .continuous))
    }

    // MARK: 9.7 Delete dialog

    private var deleteDialog: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Delete this listing?")
                .font(BFont.bold(23))
                .foregroundStyle(BColor.ink)
            Text("This can't be undone.")
                .font(BFont.regular(16))
                .foregroundStyle(LS.sheetBodyInk)
            Button {
                withAnimation(.easeOut(duration: 0.2)) { stack = ["708-170"] }
            } label: {
                Text("Delete")
                    .font(BFont.bold(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(LS.dangerInk)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            Button(action: back) {
                Text("Cancel")
                    .font(BFont.bold(15))
                    .foregroundStyle(BColor.brand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(BColor.surface)
                    .clipShape(Capsule())
                    .overlay { Capsule().stroke(BColor.brand, lineWidth: 1.2) }
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .frame(width: 345)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .bShadow(3)
    }

    // MARK: Wizard (9.8 – 9.15)

    private var wizardStep: Int {
        (wizardSteps.firstIndex(of: current) ?? 0) + 1
    }

    private var wizardStepName: String {
        switch wizardStep {
        case 1: return "Upload Pictures"
        case 2: return "Item Description"
        case 3: return "Select Location"
        case 4: return "Item Availability"
        case 5: return "Borrowing Limit"
        case 6: return "Set Deposit Fee"
        case 7: return "Care Instructions"
        default: return "Terms and Conditions"
        }
    }

    private var wizardActionTitle: String {
        switch wizardStep {
        case 6: return "Continue with $10 deposit"
        case 8: return "Preview listing"
        default: return "Continue"
        }
    }

    private var wizardScreen: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "List an Item",
                subtitle: "Step \(wizardStep) of 8 · \(wizardStepName)",
                showsBack: true,
                backAction: back)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    LStepProgress(step: wizardStep)
                    wizardContent
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            stickyAction(wizardActionTitle, action: advanceWizard)
            bottomBar
        }
    }

    private func advanceWizard() {
        if let index = wizardSteps.firstIndex(of: current), index + 1 < wizardSteps.count {
            go(wizardSteps[index + 1])
        } else {
            go("708-1634")
        }
    }

    private func stickyAction(_ title: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            primaryAction(title, action: action)
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .background(BColor.bg)
    }

    @ViewBuilder
    private var wizardContent: some View {
        switch wizardStep {
        case 1: wizardStepPhotos
        case 2: wizardStepDetails
        case 3: wizardStepPickup
        case 4: wizardStepAvailability
        case 5: wizardStepPeriod
        case 6: wizardStepDeposit
        case 7: wizardStepCare
        default: wizardStepTerms
        }
    }

    private func heading(_ text: String) -> some View {
        Text(text)
            .font(BFont.bold(26))
            .foregroundStyle(BColor.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func banner(_ text: String) -> some View {
        Text(text)
            .font(BFont.regular(16))
            .foregroundStyle(LS.sheetBodyInk)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func formField<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(label)
                .font(BFont.bold(13))
                .foregroundStyle(BColor.ink)
            content()
        }
    }

    private func inputBox<Content: View>(height: CGFloat = 48, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 8) {
            content()
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 13)
        .frame(height: height)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 1)
        }
    }

    private var chevronDown: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(BColor.ink)
    }

    // 9.8
    private var wizardStepPhotos: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading("Make a great first\nimpression")
            banner("Add up to 6 clear photos. Your first photo becomes the cover.")
            LPhoto(photo: .listPhoto1, height: 195)
            LStatusPill(text: "Cover", ink: LS.successInk, bg: LS.successSoft)
            HStack(spacing: 10) {
                LPhoto(photo: .listPhoto2, height: 85)
                LPhoto(photo: .listPhoto2, height: 85)
                addPhotoTile
                    .frame(maxWidth: .infinity)
            }
            LNoticeCard(
                title: "Good photos build trust",
                message: "Show the item, accessories and any existing marks.")
        }
    }

    private var addPhotoTile: some View {
        VStack(spacing: 5) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(BColor.brand)
            Text("3 of 6 photos")
                .font(BFont.regular(11))
                .foregroundStyle(BColor.ink)
        }
        .frame(height: 85)
        .frame(maxWidth: .infinity)
        .background(LS.successSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // 9.9
    private var wizardStepDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading("Tell us about your item")
            formField("Item name") {
                inputBox {
                    Text("Garment Steamer")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.ink)
                }
            }
            formField("Category") {
                inputBox {
                    Text("Home & living")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.ink)
                    Spacer(minLength: 0)
                    chevronDown
                }
            }
            formField("Description") {
                inputBox(height: 86) {
                    Text("Freshen up your outfit in minutes. Handheld steamer with a 250 ml tank, ready in 30 seconds. Includes a heat-resistant mitt.")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
            formField("Condition") {
                inputBox {
                    Text("Like new")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.ink)
                    Spacer(minLength: 0)
                    chevronDown
                }
            }
            Text("Used twice. No scratches or leaks.")
                .font(BFont.regular(13))
                .foregroundStyle(LS.sheetBodyInk)
        }
    }

    // 9.10
    private var wizardStepPickup: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading("Preferred meeting spot")
            formField("Pickup address") {
                inputBox {
                    Image(systemName: "mappin")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(BColor.ink)
                        .frame(width: 20)
                    Text("Bencoolen St, Singapore")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.ink)
                }
            }
            LPickupMap()
                .frame(height: 250)
            outlineAction("Pick on map") {}
            formField("Meet-up spot") {
                inputBox {
                    Text("West Wing Lobby")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.ink)
                }
            }
            Text("Your exact pickup details are shared after acceptance.")
                .font(BFont.regular(13))
                .foregroundStyle(LS.sheetBodyInk)
        }
    }

    // 9.11
    private var wizardStepAvailability: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading("When is it available?")
            banner("Choose the dates your steamer can be borrowed.")
            LCalendarCard(selected: $availableDays)
            LNoticeCard(
                title: "Available 13–27 Oct 2026",
                message: "Tap available dates to block them out.")
        }
    }

    // 9.12
    private var wizardStepPeriod: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading("Set a borrowing limit")
            banner("Keep each borrow short and sweet. Borrowers can request up to this many days.")
            VStack(alignment: .leading, spacing: 10) {
                Text("Maximum borrow period")
                    .font(BFont.regular(14))
                    .foregroundStyle(BColor.ink)
                HStack(spacing: 0) {
                    Button {
                        borrowDays = max(1, borrowDays - 1)
                    } label: {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 33, weight: .regular))
                            .foregroundStyle(BColor.brand)
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                    Spacer(minLength: 0)
                    Text("\(borrowDays) days")
                        .font(BFont.bold(40))
                        .foregroundStyle(BColor.ink)
                    Spacer(minLength: 0)
                    Button {
                        borrowDays = min(30, borrowDays + 1)
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 33, weight: .regular))
                            .foregroundStyle(BColor.brand)
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 54)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(BColor.stroke, lineWidth: 0.7)
            }
        }
    }

    // 9.13
    private var wizardStepDeposit: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text("Safety deposit")
                        .font(BFont.bold(26))
                        .foregroundStyle(BColor.ink)
                    Text("Optional")
                        .font(BFont.bold(10))
                        .foregroundStyle(LS.optionalInk)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(LS.optionalBg)
                        .clipShape(Capsule())
                }
                Text("Want extra peace of mind? Ask borrowers to put down a refundable deposit.")
                    .font(BFont.regular(14))
                    .foregroundStyle(LS.sheetBodyInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(spacing: 10) {
                depositChoiceCard(title: "No deposit", subtitle: "Get requests faster", index: 0)
                depositChoiceCard(title: "Ask for a deposit", subtitle: "Refunded in full after a safe return", index: 1)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Deposit amount (SGD)")
                    .font(BFont.bold(13))
                    .foregroundStyle(BColor.ink)
                HStack(spacing: 8) {
                    Text("$")
                        .font(BFont.bold(20))
                        .foregroundStyle(LS.sheetBodyInk)
                    TextField("50", text: $depositAmount)
                        .font(BFont.bold(26))
                        .foregroundStyle(BColor.ink)
                        .keyboardType(.numberPad)
                    Text("SGD")
                        .font(BFont.bold(12))
                        .foregroundStyle(LS.sheetBodyInk)
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(BColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(BColor.brand, lineWidth: 1.5)
                }
                HStack(spacing: 8) {
                    ForEach(["$20", "$30", "$10", "$100", "Other"], id: \.self) { amount in
                        Button {
                            quickAmount = amount
                        } label: {
                            Text(amount)
                                .font(BFont.bold(13))
                                .foregroundStyle(BColor.ink)
                                .frame(minWidth: 48)
                                .frame(height: 40)
                                .padding(.horizontal, 8)
                                .background(BColor.surface)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().stroke(quickAmount == amount ? BColor.brand : BColor.stroke,
                                                     lineWidth: quickAmount == amount ? 1.5 : 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text("Tap a quick amount or type your own. Similar items usually ask for $30 to $60.")
                    .font(BFont.regular(12))
                    .foregroundStyle(LS.sheetBodyInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            LNoticeCard(
                title: "Held by Borro, refunded after a safe return",
                message: "Borrowers pay Borro, not you. You only get paid out if there’s damage.")
        }
    }

    private func depositChoiceCard(title: String, subtitle: String, index: Int) -> some View {
        let selected = depositChoice == index
        return Button {
            depositChoice = index
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(selected ? BColor.brand : Color(hex: 0xB9BCBF), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle()
                            .fill(BColor.brand)
                            .frame(width: 10, height: 10)
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)
                    Text(subtitle)
                        .font(BFont.regular(12))
                        .foregroundStyle(LS.sheetBodyInk)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? BColor.brand : BColor.stroke, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    // 9.14
    private var wizardStepCare: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading("Help them care for it")
            banner("These numbered instructions become your Lender’s Note in the agreement.")
            ForEach(Array(careInstructions.enumerated()), id: \.offset) { index, text in
                formField("Care instruction \(index + 1)") {
                    inputBox(height: index == 2 ? 66 : 48) {
                        Text(text)
                            .font(BFont.regular(15))
                            .foregroundStyle(BColor.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
            }
            outlineAction("+ Add instruction") {
                if careInstructions.count < 5 { careInstructions.append("") }
            }
        }
    }

    // 9.15
    private var wizardStepTerms: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading("One last thing")
            VStack(alignment: .leading, spacing: 10) {
                Text("Lending on Borro")
                    .font(BFont.bold(16))
                    .foregroundStyle(BColor.ink)
                Text("You confirm that this item is safe, clean and yours to lend. Describe its condition honestly and agree on handover details with your borrower.")
                    .font(BFont.regular(14))
                    .foregroundStyle(BColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Use the one-time handover code and required condition photos. Deposits are held securely until the safe return is confirmed.")
                    .font(BFont.regular(14))
                    .foregroundStyle(BColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("If something goes wrong, report it through Borro so both sides can resolve it fairly.")
                    .font(BFont.regular(14))
                    .foregroundStyle(BColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(BColor.stroke, lineWidth: 0.7)
            }
            Button {
                termsAgreed.toggle()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(termsAgreed ? BColor.brand : BColor.surface)
                            .frame(width: 23, height: 23)
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(termsAgreed ? BColor.brand : BColor.stroke, lineWidth: 1)
                            .frame(width: 23, height: 23)
                        if termsAgreed {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    Text("I agree to the Borro Terms & Conditions and community guidelines.")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Text("Read the full Terms & Conditions ↗")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.brand)
        }
    }

    // MARK: 9.16 Listing preview

    private var previewScreen: some View {
        VStack(spacing: 0) {
            LBackBar(title: "Preview listing", titleSize: 25, onBack: back)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    LPhoto(photo: .listPhoto3, height: 190)
                    Text("Garment Steamer")
                        .font(BFont.bold(25))
                        .foregroundStyle(BColor.ink)
                    LStatusPill(text: "Like new · Home & living", ink: LS.successInk, bg: LS.successSoft)
                    Text("Freshen up your outfit in minutes. Handheld steamer with a 250 ml tank, ready in 30 seconds. Includes a heat-resistant mitt.")
                        .font(BFont.regular(15))
                        .foregroundStyle(BColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(alignment: .leading, spacing: 10) {
                        detailRow("Pickup", "West Wing Lobby,\n12 Bencoolen St, Singapore 189555")
                        detailRow("Available", "13–27 Oct 2026")
                        detailRow("Maximum period", "7 days")
                        detailRow("Safety deposit", "$10")
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(BColor.stroke, lineWidth: 0.7)
                    }
                    Text("3 photos · 3 care instructions · Terms accepted")
                        .font(BFont.regular(13))
                        .foregroundStyle(LS.sheetBodyInk)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            stickyAction("Publish", action: { go("708-1691") })
            bottomBar
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label)
                .font(BFont.regular(14))
                .foregroundStyle(LS.sheetBodyInk)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(BFont.semibold(14))
                .foregroundStyle(BColor.ink)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: 9.17 Steamer is live

    private var liveScreen: some View {
        VStack(spacing: 0) {
            LBackBar(title: "You’re all set!", titleSize: 25, onBack: back)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 52, weight: .regular))
                            .foregroundStyle(BColor.brand)
                        Text("Your steamer is live!")
                            .font(BFont.bold(29))
                            .foregroundStyle(BColor.ink)
                        Text("A little less buying. A little more sharing.")
                            .font(BFont.regular(16))
                            .foregroundStyle(LS.sheetBodyInk)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 36)
                    .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        LPhoto(photo: .listPhoto4, height: 210)
                        Text("Garment Steamer")
                            .font(BFont.bold(16))
                            .foregroundStyle(BColor.ink)
                        HStack(spacing: 10) {
                            Text("Listing status")
                                .font(BFont.regular(14))
                                .foregroundStyle(LS.sheetBodyInk)
                            Spacer(minLength: 0)
                            Text("Active")
                                .font(BFont.semibold(16))
                                .foregroundStyle(LS.activeGreen)
                        }
                        Text("Bencoolen St · Available 13–27 Oct")
                            .font(BFont.regular(13))
                            .foregroundStyle(LS.sheetBodyInk)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(BColor.stroke, lineWidth: 0.7)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            stickyAction("View My Listings") {
                withAnimation(.easeOut(duration: 0.2)) { stack = ["708-170"] }
            }
            bottomBar
        }
    }
}

// MARK: - Lend tab root (9.1 entry point)

struct LendingTabView: View {
    var body: some View {
        // AppShell supplies the real tab bar for tab roots.
        LendingFlow(startScreen: nil, showsBottomBar: false)
    }
}

// MARK: - Shared pieces

private struct LFlowTabBar: View {
    var selected: AppTab
    var onSelect: (AppTab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(BColor.stroke).frame(height: 1)
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        onSelect(tab)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.safeIcon(selected: selected == tab))
                                .font(.system(size: 21, weight: .regular))
                                .frame(height: 24)
                            Text(tab.rawValue)
                                .font(BFont.tabLabel)
                        }
                        .foregroundStyle(selected == tab ? BColor.brand : BColor.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(BColor.surface)
    }
}

private struct LBackBar: View {
    var title: String
    var titleSize: CGFloat = 21
    var onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            Text(title)
                .font(BFont.bold(titleSize))
                .foregroundStyle(BColor.ink)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, BSpace.screen)
        .frame(height: 64)
    }
}

private struct LWordmark: View {
    var body: some View {
        BLogoMark(width: 72)
            .frame(width: 72, height: 34, alignment: .leading)
    }
}

/// Fills the given frame and clips — BImageView alone does not constrain a
/// fill-mode image, which otherwise bleeds out of listing cards.
private struct LPhoto: View {
    var photo: BPhoto
    var width: CGFloat? = nil
    var height: CGFloat
    var radius: CGFloat = BRadius.photo

    var body: some View {
        if let width {
            BImageView(photo: photo, cornerRadius: 0)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        } else {
            BImageView(photo: photo, cornerRadius: 0)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }
}

private struct LStatusPill: View {
    var text: String
    var ink: Color
    var bg: Color

    var body: some View {
        Text(text)
            .font(BFont.bold(11))
            .foregroundStyle(ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bg)
            .clipShape(Capsule())
    }
}

private struct LNoticeCard: View {
    var title: String
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            Text(message)
                .font(BFont.regular(13))
                .foregroundStyle(LS.sheetBodyInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LS.successSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct LActiveListingCard: View {
    var listing: LActiveListing
    var onMore: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            LPhoto(photo: listing.photo, width: 74, height: 80)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    Text(listing.title)
                        .font(BFont.bold(14))
                        .foregroundStyle(BColor.ink)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Button(action: onMore) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(BColor.ink)
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 19)
                LStatusPill(text: listing.status, ink: listing.statusInk, bg: listing.statusBg)
                Text(listing.detail)
                    .font(BFont.regular(11))
                    .foregroundStyle(LS.sheetBodyInk)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow()
    }
}

private struct LPastListingCard: View {
    var listing: LPastListing
    var onMore: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            LPhoto(photo: listing.photo, width: 74, height: 80)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(listing.title)
                        .font(BFont.bold(14))
                        .foregroundStyle(BColor.ink)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Button(action: onMore) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(BColor.ink)
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 19)
                HStack(spacing: 5) {
                    BAvatarView(photo: listing.avatar, initials: "", size: 19)
                    Text(listing.detail)
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.ink)
                        .lineLimit(1)
                }
                .frame(height: 19)
                LStatusPill(text: listing.status, ink: listing.statusInk, bg: listing.statusBg)
                Spacer(minLength: 0)
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow()
    }
}

// MARK: - Wizard components

private struct LStepProgress: View {
    var step: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...8, id: \.self) { index in
                Capsule()
                    .fill(index <= step ? BColor.brand : BColor.stroke)
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Pick-up map (9.10)

private struct LPickupMap: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .fill(LS.mapBg)

            Rectangle()
                .fill(Color.white)
                .frame(width: 69, height: 250)
                .offset(x: 82)
            Rectangle()
                .fill(Color.white)
                .frame(width: 353, height: 72)
                .offset(y: 25)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LS.mapBlockB)
                .frame(width: 85, height: 55)
                .offset(x: 10, y: 6)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LS.mapBlockA)
                .frame(width: 90, height: 60)
                .offset(x: 246, y: 182)

            Ellipse()
                .fill(LS.successInk.opacity(0.08))
                .overlay { Ellipse().stroke(LS.successInk, lineWidth: 1.5) }
                .frame(width: 200, height: 180)
                .offset(x: 72, y: 41)

            Circle()
                .fill(BColor.brand)
                .frame(width: 16, height: 16)
                .overlay { Circle().stroke(.white, lineWidth: 3) }
                .offset(x: 166, y: 123)

            Text("Bras Basah Rd")
                .font(BFont.regular(10))
                .foregroundStyle(LS.sheetBodyInk)
                .offset(x: 163, y: 70)

            mapPin("Blk 12")
                .offset(x: 33, y: 16)
            mapPin("Blk 48")
                .offset(x: 199, y: 145)

            Text("SINGAPORE · BENCOOLEN")
                .font(BFont.regular(11))
                .tracking(0.6)
                .foregroundStyle(LS.sheetBodyInk)
                .offset(x: 12, y: 214)
        }
        .frame(width: 353, height: 250)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }

    private func mapPin(_ label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 15))
                .foregroundStyle(LS.successInk)
            Text(label)
                .font(BFont.bold(12))
                .foregroundStyle(.black)
        }
        .padding(7)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - October calendar (9.11)

private struct LCalendarCard: View {
    @Binding var selected: Set<Int>

    private let weeks: [[Int?]] = [
        [nil, nil, nil, 1, 2, 3, 4],
        [5, 6, 7, 8, 9, 10, 11],
        [12, 13, 14, 15, 16, 17, 18],
        [19, 20, 21, 22, 23, 24, 25],
        [26, 27, 28, 29, 30, 31, nil]
    ]

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 18, height: 18)
                Spacer()
                Text("October 2026")
                    .font(BFont.bold(16))
                    .foregroundStyle(BColor.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 18, height: 18)
            }
            .frame(height: 19)

            HStack(spacing: 0) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(BFont.regular(14))
                        .foregroundStyle(LS.sheetBodyInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 19)
                }
            }

            VStack(spacing: 3.8) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 0) {
                        ForEach(Array(week.enumerated()), id: \.offset) { index, day in
                            dayCell(day, row: week, index: index)
                        }
                    }
                }
            }
            .frame(height: 155)

            HStack {
                Text("Select start and end dates")
                    .font(BFont.regular(11))
                    .foregroundStyle(LS.sheetBodyInk)
                Spacer(minLength: 0)
            }
            .frame(height: 13)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    @ViewBuilder
    private func dayCell(_ day: Int?, row: [Int?], index: Int) -> some View {
        if let day {
            let isSelected = selected.contains(day)
            let previous = index > 0 ? row[index - 1] : nil
            let next = index < row.count - 1 ? row[index + 1] : nil
            let connectLeft = previous.map { selected.contains($0) } ?? false
            let connectRight = next.map { selected.contains($0) } ?? false
            Text("\(day)")
                .font(BFont.regular(14))
                .foregroundStyle(isSelected ? .white : BColor.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background {
                    if isSelected {
                        UnevenRoundedRectangle(
                            topLeadingRadius: connectLeft ? 0 : 6,
                            bottomLeadingRadius: connectLeft ? 0 : 6,
                            bottomTrailingRadius: connectRight ? 0 : 6,
                            topTrailingRadius: connectRight ? 0 : 6,
                            style: .continuous)
                            .fill(BColor.brand)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selected.contains(day) { selected.remove(day) } else { selected.insert(day) }
                }
        } else {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 28)
        }
    }
}

// MARK: - Sort / filter sheet (9.2, 9.4)

private enum LSortKind { case active, past }

private struct LSortFilterSheet: View {
    var kind: LSortKind
    @Binding var statuses: Set<String>
    @Binding var sort: String
    var onClear: () -> Void
    var onApply: () -> Void

    private var statusRows: [[String]] {
        kind == .active
            ? [["Available", "Handover pending"], ["On loan", "Overdue", "Paused"]]
            : [["Returned", "Cancelled"]]
    }

    private var counts: [String: Int] {
        ["Available": 1, "Handover pending": 1, "On loan": 1, "Overdue": 1, "Paused": 0]
    }

    private var sortRows: [[String]] {
        kind == .active
            ? [["Due soonest", "Newest listed"], ["Oldest listed", "Name A–Z", "Most borrowed"], ["Highest rated"]]
            : [["Most recent first", "Oldest first"], ["Name A–Z", "Most borrowed"], ["Highest rated"]]
    }

    private var actionTitle: String {
        kind == .active ? "Show 1 item" : "Show results"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text("Sort / Filter")
                    .font(BFont.bold(20))
                    .foregroundStyle(BColor.ink)
                Spacer(minLength: 0)
                Button(action: onClear) {
                    Text("Clear all")
                        .font(BFont.bold(14))
                        .foregroundStyle(BColor.brand)
                }
                .buttonStyle(.plain)
            }
            .frame(height: 24)

            Text("Status")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(statusRows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.self) { option in
                            statusChip(option)
                        }
                    }
                }
            }

            Text("Sort by")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(sortRows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 8) {
                        ForEach(row, id: \.self) { option in
                            sortChip(option)
                        }
                    }
                }
            }

            Button(action: onApply) {
                Text(actionTitle)
                    .font(BFont.bold(14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(BColor.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, BSpace.xl)
        .padding(.bottom, 34)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.sheet, style: .continuous))
    }

    private func statusChip(_ title: String) -> some View {
        let selected = statuses.contains(title)
        let count = counts[title]
        let label = count.map { selected ? "\(title) ✓ \($0)" : "\(title) \($0)" } ?? (selected ? "\(title) ✓" : title)
        return Button {
            if selected { statuses.remove(title) } else { statuses.insert(title) }
        } label: {
            Text(label)
                .font(selected ? BFont.bold(14) : BFont.regular(14))
                .foregroundStyle(selected ? BColor.ink : Color.black)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(BColor.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(selected ? BColor.brand : BColor.stroke,
                                     lineWidth: selected ? 1.5 : 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func sortChip(_ title: String) -> some View {
        let selected = sort == title
        return Button {
            sort = title
        } label: {
            Text(title)
                .font(selected ? BFont.bold(14) : BFont.regular(14))
                .foregroundStyle(selected ? BColor.ink : Color.black)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(BColor.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(selected ? BColor.brand : BColor.stroke,
                                     lineWidth: selected ? 1.5 : 1)
                }
        }
        .buttonStyle(.plain)
    }
}
