import SwiftUI

// MARK: - Section 11 · Other screens (Borrow Later, Wishlist, AI chat)
//
// Figma node 708:2690 — five artboards:
//   708-2691 11.1 Item details · Borrow Later (bottom sheet presented)
//   708-2877 11.2 Borrow Later · pick dates (sheet only, over scrim)
//   708-2984 11.3 Request sent
//   708-3039 11.4 Wishlist
//   708-3121 11.5 Ask Borro (AI chat)
//
// These screens do not form a single linear journey in the file, so the flow is
// a small state machine: item details → date sheet → request sent, with the
// wishlist and the AI companion reachable from item details (and the wishlist
// also linked from the Home / You tabs).

// MARK: - Figma-spec colours (design/figma/spec/708-2690.md)

private enum OS {
    static let successInk = Color(hex: 0x1E8E5A)
    static let successSoft = Color(hex: 0xE8F4EC)
    static let amberInk = Color(hex: 0x92600A)
    static let amberSoft = Color(hex: 0xFFF3D9)
    static let handle = Color(hex: 0xB9BCBF)
    static let sheetTitleInk = Color(hex: 0x12201A)
    static let sheetSubInk = Color(hex: 0x5E6561)
    static let bodyInk = Color(hex: 0x68766E)
    static let dotMuted = Color(hex: 0xB8C4BB)
    static let scrim = Color(hex: 0x14231C)
    static let sectionBackdrop = Color(hex: 0x444444)
    static let borrowNow = Color(hex: 0xF5A524)
    static let heartRed = Color(hex: 0xD64545)
}

// MARK: - Wishlist fixture

private struct OWishItem: Identifiable {
    let id: String
    let title: String
    let owner: Person
    let photo: BPhoto
    let rating: Double
    let reviews: Int
    let location: String
}

private let oWishlist: [OWishItem] = [
    OWishItem(id: "steamer", title: "Garment Steamer", owner: BPeople.thomas,
              photo: .steamer, rating: 5.0, reviews: 10, location: "Bencoolen St"),
    OWishItem(id: "portable", title: "Portable Steamer", owner: BPeople.matthew,
              photo: .projector, rating: 4.7, reviews: 14, location: "Bras Basah Rd"),
    OWishItem(id: "screen", title: "Steamer Screen", owner: BPeople.jessica,
              photo: .projectorScreen, rating: 4.6, reviews: 20, location: "Plaza Singapura"),
    OWishItem(id: "football", title: "Football", owner: BPeople.lebron,
              photo: .football, rating: 5.0, reviews: 10, location: "West Wing")
]

// MARK: - Flow

struct OtherScreensFlow: View {
    @EnvironmentObject private var router: AppRouter

    var startScreen: String? = nil

    @State private var stack: [String] = []
    @State private var showDates = false
    @State private var selectedDays: Set<Int> = [18, 19]
    @State private var isSaved = false
    @State private var savedIDs: Set<String> = ["steamer", "portable", "screen", "football"]
    @State private var chatDraft = ""
    @State private var sentMessages: [String] = []

    var body: some View {
        ZStack {
            screen
        }
        .ignoresSafeArea(edges: .bottom)
        .bBackground()
        .onAppear(perform: seed)
    }

    private var current: String { stack.last ?? "708-2691" }

    @ViewBuilder
    private var screen: some View {
        switch current {
        case "708-2877":
            ZStack {
                OS.sectionBackdrop.ignoresSafeArea()
                OS.scrim.opacity(0.40)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { back() }
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    dateSheet
                }
                .ignoresSafeArea(edges: .bottom)
            }
        case "708-2984":
            requestSentScreen
        case "708-3039":
            wishlistScreen
        case "708-3121":
            chatScreen
        default:
            ZStack {
                itemDetailsScreen
                if showDates {
                    ZStack(alignment: .bottom) {
                        OS.scrim.opacity(0.40)
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture { withAnimation(.easeOut(duration: 0.2)) { showDates = false } }
                        dateSheet.ignoresSafeArea(edges: .bottom)
                    }
                }
            }
        }
    }

    private func seed() {
        guard stack.isEmpty else { return }
        showDates = startScreen == nil || startScreen == "708-2691"
        stack = [startScreen ?? "708-2691"]
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
        switch tab {
        case .borro:
            if stack.count > 1 {
                showDates = false
                withAnimation(.easeOut(duration: 0.2)) { stack = ["708-2691"] }
            } else {
                router.switchTab(.borro)
            }
        default:
            router.switchTab(tab)
        }
    }

    @ViewBuilder
    private func bottomBar(_ selected: AppTab) -> some View {
        OFlowTabBar(selected: selected, onSelect: selectTab)
    }

    // MARK: 11.1 Item details

    private var itemDetailsScreen: some View {
        VStack(spacing: 0) {
            OAppBar(
                title: "Item details",
                titleSize: 25,
                trailing: AnyView(
                    HStack(spacing: 10) {
                        Button { go("708-3039") } label: {
                            Image(systemName: "heart")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(BColor.brand)
                                .frame(width: 26, height: 26)
                        }
                        .buttonStyle(.plain)
                        Button { go("708-3121") } label: {
                            Image(systemName: "bubble.left.and.text.bubble.right")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(BColor.brand)
                                .frame(width: 26, height: 26)
                        }
                        .buttonStyle(.plain)
                    }
                ),
                onBack: back)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    OPhoto(photo: .steamer, height: 145)
                    HStack(spacing: 5) {
                        Capsule().fill(BColor.brand).frame(width: 18, height: 5)
                        Circle().fill(OS.dotMuted).frame(width: 5, height: 5)
                        Circle().fill(OS.dotMuted).frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                    HStack(spacing: 12) {
                        Text("Garment Steamer")
                            .font(BFont.bold(23))
                            .foregroundStyle(BColor.ink)
                        Spacer(minLength: 0)
                        Button {
                            isSaved.toggle()
                        } label: {
                            Image(systemName: isSaved ? "heart.fill" : "heart")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(BColor.brand)
                                .frame(width: 22, height: 22)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(height: 31)
                    Text("Freshen up your outfit in minutes. Lightweight handheld steamer, ready in 30 seconds. Includes a heat-resistant mitt.")
                        .font(BFont.regular(14))
                        .foregroundStyle(OS.bodyInk)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 0) {
                        OStatusPill(text: "Deposit: $10", ink: OS.successInk, bg: OS.successSoft)
                        Spacer(minLength: 0)
                        Text("Bencoolen St")
                            .font(BFont.regular(12))
                            .foregroundStyle(OS.bodyInk)
                    }
                    memberRow
                    availabilityBlock
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            borrowActions
            bottomBar(.borro)
        }
    }

    private var memberRow: some View {
        HStack(spacing: 10) {
            BAvatarView(photo: BPeople.thomas.photo, initials: BPeople.thomas.initials, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text("Thomas")
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(BColor.brand)
                }
                Text("★ 4.8 · Credibility 86/100 · High")
                    .font(BFont.regular(11))
                    .foregroundStyle(OS.bodyInk)
            }
            Spacer(minLength: 0)
            Button {
                router.push(.person(BPeople.thomas))
            } label: {
                Text("View profile")
                    .font(BFont.bold(11))
                    .foregroundStyle(BColor.brand)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 38)
    }

    private var availabilityBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("October 2026 · Availability")
                .font(BFont.bold(13))
                .foregroundStyle(BColor.ink)
            HStack(spacing: 5) {
                ForEach([15, 16, 17, 18, 19, 20, 21], id: \.self) { day in
                    let free = day >= 17
                    Text("\(day)")
                        .font(BFont.regular(12))
                        .foregroundStyle(free ? BColor.brand : OS.bodyInk)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(free ? OS.successSoft : Color(hex: 0xEDF0EC))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
            }
            Text("Grey dates are busy · View full calendar with Borrow Later")
                .font(BFont.regular(10))
                .foregroundStyle(OS.bodyInk)
                .lineLimit(1)
        }
    }

    private var borrowActions: some View {
        HStack(spacing: 10) {
            Button {
                router.push(.flow(.request, screen: "691-4767"))
            } label: {
                Text("⚡ Borrow Now")
                    .font(BFont.bold(15))
                    .foregroundStyle(BColor.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(OS.borrowNow)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                go("708-2877")
            } label: {
                Text("Borrow Later")
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
        .padding(.horizontal, BSpace.screen)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(BColor.bg)
    }

    // MARK: Date picker sheet (11.1 overlay / 11.2)

    private var dateSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Capsule().fill(OS.handle).frame(width: 36, height: 4)
                Spacer()
            }
            .padding(.top, 14)
            .padding(.bottom, 8)

            Text("Choose your borrowing dates")
                .font(BFont.bold(20))
                .foregroundStyle(OS.sheetTitleInk)
            Text("Tap every day you can hand it over.")
                .font(BFont.regular(13))
                .foregroundStyle(OS.sheetSubInk)
                .padding(.top, 4)
                .padding(.bottom, 16)

            OCalendarCard(selected: $selectedDays)

            ONoticeCard(
                title: "18 Oct → 19 Oct · 1 day",
                message: "Normal priority · Thomas must accept your request.")
                .padding(.top, 16)

            Button {
                withAnimation(.easeOut(duration: 0.2)) { showDates = false }
                go("708-2984")
            } label: {
                Text("Send Request")
                    .font(BFont.bold(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(BColor.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.bottom, 17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.sheet, style: .continuous))
    }

    // MARK: 11.3 Request sent

    private var requestSentScreen: some View {
        VStack(spacing: 0) {
            OAppBar(title: "Request sent", titleSize: 25, onBack: back)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 18) {
                        ZStack {
                            Circle().fill(OS.successSoft).frame(width: 86, height: 86)
                            Image(systemName: "checkmark")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(BColor.brand)
                        }
                        Text("Good things are on the\nway.")
                            .font(BFont.bold(27))
                            .foregroundStyle(BColor.ink)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 45)
                        Text("Request sent – waiting for Thomas to accept")
                            .font(BFont.regular(16))
                            .foregroundStyle(BColor.ink)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 45)
                    .padding(.bottom, 20)

                    requestedItemCard
                    ONoticeCard(
                        title: "No deposit charged yet",
                        message: "We’ll let you know when your lender accepts. Then you can arrange the handover together.")
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            VStack(spacing: 0) {
                Button {
                    router.switchTab(.borro)
                } label: {
                    Text("My Borrowing")
                        .font(BFont.bold(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(BColor.brand)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)
            bottomBar(.borro)
        }
    }

    private var requestedItemCard: some View {
        HStack(spacing: 14) {
            OPhoto(photo: BPhoto(key: "list_photo5"), width: 90, height: 90)
            VStack(alignment: .leading, spacing: 8) {
                Text("Garment Steamer")
                    .font(BFont.bold(16))
                    .foregroundStyle(BColor.ink)
                Text("18–19 Oct 2026")
                    .font(BFont.regular(14))
                    .foregroundStyle(BColor.ink)
                OStatusPill(text: "Pending acceptance", ink: OS.amberInk, bg: OS.amberSoft)
                Spacer(minLength: 0)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow()
    }

    // MARK: 11.4 Wishlist

    private var wishlistScreen: some View {
        VStack(spacing: 0) {
            OAppBar(title: "Wishlist", titleSize: 21, onBack: back)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("A little collection of things you love.")
                        .font(BFont.regular(14))
                        .foregroundStyle(OS.bodyInk)
                    LazyVGrid(
                        columns: [
                            GridItem(.fixed(170.5), spacing: 12),
                            GridItem(.fixed(170.5), spacing: 12)
                        ],
                        alignment: .leading,
                        spacing: 12
                    ) {
                        ForEach(oWishlist.filter { savedIDs.contains($0.id) }) { item in
                            wishlistCard(item)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            bottomBar(.home)
        }
    }

    private func wishlistCard(_ item: OWishItem) -> some View {
        Button {
            go("708-2691")
        } label: {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 5) {
                    BAvatarView(photo: item.owner.photo, initials: item.owner.initials, size: 22)
                    Text(item.owner.name)
                        .font(BFont.semibold(11))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(BColor.brand)
                    Spacer(minLength: 0)
                }
                .frame(height: 22)
                OPhoto(photo: item.photo, height: 98)
                HStack(spacing: 3) {
                    Text(item.title)
                        .font(BFont.bold(12))
                        .foregroundStyle(BColor.ink)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Button {
                        savedIDs.remove(item.id)
                    } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(OS.heartRed)
                            .frame(width: 15, height: 15)
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 16)
                Text("★ \(String(format: "%.1f", item.rating)) (\(item.reviews) reviews)")
                    .font(BFont.regular(11))
                    .foregroundStyle(BColor.ink)
                Text(item.location)
                    .font(BFont.regular(10))
                    .foregroundStyle(OS.bodyInk)
                Spacer(minLength: 0)
            }
            .padding(9)
            .frame(width: 170.5, height: 211, alignment: .top)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: 11.5 Ask Borro

    private var chatScreen: some View {
        VStack(spacing: 0) {
            OAppBar(
                title: "B · Ask me",
                titleSize: 21,
                subtitle: "About this item: Garment Steamer",
                onBack: back)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    OStatusPill(text: "Your item companion", ink: OS.successInk, bg: OS.successSoft)
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("How do I set up an Garment Steamer?")
                                .font(BFont.regular(15))
                                .foregroundStyle(BColor.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("7:45 pm ✓✓")
                                .font(BFont.regular(10))
                                .foregroundStyle(OS.bodyInk)
                        }
                        .padding(14)
                        .frame(maxWidth: 290, alignment: .leading)
                        .background(OS.successSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    borroAnswerCard
                    youtubeCard
                    Text("Always follow your lender’s care instructions.")
                        .font(BFont.regular(11))
                        .foregroundStyle(OS.bodyInk)
                    ForEach(Array(sentMessages.enumerated()), id: \.offset) { _, message in
                        HStack {
                            Spacer(minLength: 0)
                            Text(message)
                                .font(BFont.regular(15))
                                .foregroundStyle(BColor.ink)
                                .padding(14)
                                .background(OS.successSoft)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            chatComposer
            bottomBar(.borro)
        }
    }

    private var borroAnswerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Borro")
                .font(BFont.bold(16))
                .foregroundStyle(BColor.brand)
            Text("1. Tripod thread is on the base centre.\n\n2. Hold power for 3 sec, then tap the top pod twice for the menu.\n\n3. Source → HDMI.\n\n4. Autofocus runs on its own.")
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
        .bShadow()
    }

    private var youtubeCard: some View {
        HStack(spacing: 12) {
            OPhoto(photo: BPhoto(key: "speaker_desk2"), width: 85, height: 70)
            VStack(alignment: .leading, spacing: 5) {
                Text("Garment Steamer – Quick-use guide")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("▶ YouTube · 2:14")
                    .font(BFont.regular(12))
                    .foregroundStyle(OS.bodyInk)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow()
    }

    private var chatComposer: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(BColor.brand)
                TextField("Ask Borro..", text: $chatDraft)
                    .font(BFont.regular(14))
                Button {
                    sendChat()
                } label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(BColor.brand)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 13)
            .frame(height: 48)
            .background(BColor.surface)
            .clipShape(Capsule())
            .overlay { Capsule().stroke(BColor.stroke, lineWidth: 1) }
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, 10)
        .padding(.bottom, 18)
        .background(BColor.bg)
    }

    private func sendChat() {
        let text = chatDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        sentMessages.append(text)
        chatDraft = ""
    }
}

// MARK: - Shared pieces

private struct OFlowTabBar: View {
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

private struct OAppBar: View {
    var title: String
    var titleSize: CGFloat = 25
    var subtitle: String? = nil
    var trailing: AnyView? = nil
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
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BFont.bold(titleSize))
                    .foregroundStyle(BColor.ink)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            if let trailing { trailing }
        }
        .padding(.horizontal, BSpace.screen)
        .frame(height: 64)
    }
}

/// Fills the given frame and clips — BImageView alone does not constrain a
/// fill-mode image, which otherwise bleeds out of cards.
private struct OPhoto: View {
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

private struct OStatusPill: View {
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

private struct ONoticeCard: View {
    var title: String
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            Text(message)
                .font(BFont.regular(13))
                .foregroundStyle(OS.bodyInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OS.successSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - October calendar (date sheet)

private struct OCalendarCard: View {
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
                        .foregroundStyle(OS.bodyInk)
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
                    .foregroundStyle(OS.bodyInk)
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
