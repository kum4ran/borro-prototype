import SwiftUI

// Request — Figma section 2 · Request (James)
//
//   691-4767  2.1 James · Item details · Garment Steamer
//   691-4822  2.2 James · Borrow request (sheet over 2.1)
//   691-5008  2.3 James · Request sent · waiting for Thomas
//   691-5063  2.4 James · My Borrowing (also the Borro tab root)
//
// The flow is a stack of artboard slugs so every frame can be deep-linked
// through `startScreen` (see docs/TEAM_BRIEF.md §2).

// MARK: - Spec colours shared by sections 2 & 3
//
// Values are lifted verbatim from the Figma frames. Anything already in
// Tokens.swift is reused instead of duplicated.

enum RQPalette {
    static let reject       = Color(hex: 0xD64545)   // Reject outline + label
    static let urgentFill   = Color(hex: 0xFFF3D9)   // URGENT chip
    static let urgentInk    = Color(hex: 0x92600A)   // URGENT chip label / stars
    static let freeFill     = Color(hex: 0xE8F4EC)   // "Free" range / deposit / verified
    static let freeInk      = Color(hex: 0x1E8E5A)   // "Free" range / deposit label
    static let busyFill     = Color(hex: 0xEDF0EC)   // busy range / progress track
    static let orangeAction = Color(hex: 0xF5A524)   // "Borrow Now" while choosing dates
    static let dotInactive  = Color(hex: 0xB8C4BB)   // carousel dot, unselected
    static let tooltipGreen = Color(hex: 0xAEE5C4)   // credibility tooltip footer
    static let scrimInk     = Color(hex: 0x14231C)   // dialog / sheet scrim colour
}

// MARK: - Shared chrome

/// Bottom navigation rendered inside a pushed flow screen (the app shell only
/// renders its tab bar on tab roots, but the Figma frames keep it visible).
struct RQTabBar: View {
    @EnvironmentObject private var router: AppRouter
    var selected: AppTab

    var body: some View {
        BTabBar(selection: Binding(
            get: { selected },
            set: { router.switchTab($0) }
        ))
        .background(BColor.surface)
    }
}

/// 64pt app bar with the 25pt heading used by 2.4, 3.4 and 3.6.
struct RQBigAppBar: View {
    var title: String
    var backAction: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: BSpace.md) {
            Button {
                if let backAction { backAction() } else { dismiss() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)

            Text(title)
                .font(BFont.bold(25))
                .foregroundStyle(BColor.ink)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, BSpace.screen)
        .frame(height: BMetric.appBarHeight)
        .background(BColor.bg)
    }
}

/// Small uppercase status pill (URGENT / Pending / Borrow Now).
struct RQStatusChip: View {
    var text: String
    var foreground: Color = RQPalette.urgentInk
    var background: Color = RQPalette.urgentFill

    var body: some View {
        Text(text)
            .font(BFont.bold(11))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background)
            .clipShape(Capsule())
    }
}

extension View {
    /// The white 12pt-radius card used all over sections 2 and 3.
    func rqCard(padding: CGFloat = 12, radius: CGFloat = BRadius.card) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(BColor.stroke, lineWidth: 0.7)
            }
            .bShadow(1)
    }
}

// MARK: - October 2026 month calendar
//
// Used by the 2.2 date sheet and the 3.3 expanded request. Figma draws the
// selected range as one continuous blue pill, so adjacent selected days share
// corners.

struct RQMonthCalendar: View {
    enum WeekStart { case sunday, monday }

    var monthTitle: String = "October 2026"
    var weekStart: WeekStart = .monday
    var selected: Set<Int> = [18, 19]
    var busy: Set<Int> = []
    var showsMonthHeader: Bool = true
    var onTapDay: ((Int) -> Void)? = nil

    private let totalDays = 31

    /// 1 October 2026 is a Thursday.
    private var leadingBlanks: Int { weekStart == .monday ? 3 : 4 }

    private var weekdayLabels: [String] {
        weekStart == .monday
            ? ["M", "T", "W", "T", "F", "S", "S"]
            : ["S", "M", "T", "W", "T", "F", "S"]
    }

    private var rows: [[Int?]] {
        var cells: [Int?] = Array(repeating: nil, count: leadingBlanks)
        cells.append(contentsOf: (1...totalDays).map { Optional($0) })
        while cells.count % 7 != 0 { cells.append(nil) }
        let rowCount = cells.count / 7
        return (0..<rowCount).map { index in
            Array(cells[(index * 7)..<(index * 7 + 7)])
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            if showsMonthHeader { monthHeader }
            weekdayHeader
            VStack(spacing: 3.8) {
                ForEach(rows.indices, id: \.self) { index in
                    weekRow(rows[index])
                }
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BColor.ink)
                .frame(width: 18, height: 18)
            Spacer()
            Text(monthTitle)
                .font(BFont.bold(16))
                .foregroundStyle(BColor.ink)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BColor.ink)
                .frame(width: 18, height: 18)
        }
        .frame(height: 19)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                Text(weekdayLabels[index])
                    .font(BFont.regular(14))
                    .foregroundStyle(BColor.inkSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 19)
    }

    private func weekRow(_ row: [Int?]) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                let day = row[index]
                let isSelected = day.map { selected.contains($0) } ?? false
                let isBusy = day.map { busy.contains($0) } ?? false
                let leftSelected = index > 0 && (row[index - 1].map { selected.contains($0) } ?? false)
                let rightSelected = index < 6 && (row[index + 1].map { selected.contains($0) } ?? false)
                cell(day: day,
                     isSelected: isSelected,
                     isBusy: isBusy,
                     roundLeft: !leftSelected,
                     roundRight: !rightSelected)
            }
        }
        .frame(height: 28)
    }

    @ViewBuilder
    private func cell(day: Int?, isSelected: Bool, isBusy: Bool,
                      roundLeft: Bool, roundRight: Bool) -> some View {
        if let day, let onTapDay {
            Button { onTapDay(day) } label: {
                cellContent(day: day, isSelected: isSelected, isBusy: isBusy,
                            roundLeft: roundLeft, roundRight: roundRight)
            }
            .buttonStyle(.plain)
        } else {
            cellContent(day: day, isSelected: isSelected, isBusy: isBusy,
                        roundLeft: roundLeft, roundRight: roundRight)
        }
    }

    private func cellContent(day: Int?, isSelected: Bool, isBusy: Bool,
                             roundLeft: Bool, roundRight: Bool) -> some View {
        ZStack {
            if isSelected {
                UnevenRoundedRectangle(
                    topLeadingRadius: roundLeft ? 8 : 0,
                    bottomLeadingRadius: roundLeft ? 8 : 0,
                    bottomTrailingRadius: roundRight ? 8 : 0,
                    topTrailingRadius: roundRight ? 8 : 0,
                    style: .continuous
                )
                .fill(BColor.brand)
            } else if isBusy {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(RQPalette.busyFill)
            }
            if let day {
                Text("\(day)")
                    .font(BFont.regular(14))
                    .foregroundStyle(isSelected ? Color.white : (isBusy ? BColor.inkSecondary : BColor.ink))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 28)
        .contentShape(Rectangle())
    }
}

// MARK: - Flow

struct RequestFlow: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: BorroStore

    var startScreen: String? = nil

    @State private var stack: [String] = []
    @State private var showDateSheet = false
    @State private var photoPage = 0
    @State private var selectedDays: Set<Int> = [18, 19]
    @State private var didApplyStart = false

    private let entryScreen = "691-4767"
    private var current: String { stack.last ?? entryScreen }

    var body: some View {
        content
            .bBackground()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                RQTabBar(selected: .borro)
            }
            .sheet(isPresented: $showDateSheet) {
                dateSheet
                    .presentationDetents([.height(548)])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(BRadius.sheet)
            }
            .onAppear(perform: applyStartScreen)
    }

    @ViewBuilder
    private var content: some View {
        switch current {
        case "691-5008":
            RequestSentView(
                item: store.activeItem,
                onBack: back,
                onChat: openChat,
                onMyBorrowing: openMyBorrowing
            )
        case "691-5063":
            MyBorrowingContent(onOpenBorrow: { router.push(.flow(.request, screen: "691-5008")) })
        default:
            itemDetails
        }
    }

    private var itemDetails: some View {
        RequestItemDetailsView(
            item: store.activeItem,
            modalBackdrop: showDateSheet,
            saved: store.isSaved(store.activeItem),
            photoPage: $photoPage,
            onBack: back,
            onBorrowNow: {
                store.mode = .now
                selectedDays = [18, 19]
                showDateSheet = true
            },
            onBorrowLater: {
                store.mode = .later
                selectedDays = [18, 19]
                showDateSheet = true
            },
            onOwner: { router.push(.person(store.activeItem.owner)) },
            onHeart: { store.toggleSaved(store.activeItem) }
        )
    }

    // MARK: 2.2 date sheet

    private var dateSheet: some View {
        BSheetSurface {
            VStack(alignment: .leading, spacing: 0) {
                Text("Choose your borrowing dates")
                    .font(BFont.bold(20))
                    .foregroundStyle(BColor.ink)
                Text("Tap every day you can hand it over.")
                    .font(BFont.regular(13))
                    .foregroundStyle(BColor.inkSecondary)
                    .padding(.top, 4)

                calendarCard
                    .padding(.top, 16)

                dateNotice
                    .padding(.top, 16)

                Button {
                    sendRequest()
                } label: {
                    BButtonLabel("Send Request")
                }
                .buttonStyle(BButtonStyle(height: 48))
                .padding(.top, 18)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            RQMonthCalendar(
                weekStart: .monday,
                selected: selectedDays,
                onTapDay: { toggleDay($0) }
            )
            Text("Select start and end dates")
                .font(BFont.regular(11))
                .foregroundStyle(BColor.inkSecondary)
        }
        .rqCard()
    }

    private var dateNotice: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(rangeHeadline)
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            Text("Urgent · Thomas gets an instant notification and must accept.")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(RQPalette.freeFill)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }

    private var rangeHeadline: String {
        guard let low = selectedDays.min(), let high = selectedDays.max() else {
            return "Select a start and end date"
        }
        let days = max(1, high - low)
        return "\(low) Oct → \(high) Oct · \(days) day"
    }

    private func toggleDay(_ day: Int) {
        withAnimation(.easeOut(duration: 0.12)) {
            if selectedDays.contains(day) {
                selectedDays.remove(day)
            } else {
                selectedDays.insert(day)
            }
        }
    }

    private func sendRequest() {
        let calendar = Calendar.current
        if let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 18)),
           let end = calendar.date(from: DateComponents(year: 2026, month: 10, day: 19)) {
            store.request.dates = DateRange(start: start, end: end)
        }
        store.request.mode = store.mode
        showDateSheet = false
        go("691-5008")
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

    private func openChat() {
        router.push(.flow(.schedule, screen: "691-5576"))
    }

    private func openMyBorrowing() {
        router.switchTab(.borro)
    }

    private func applyStartScreen() {
        guard !didApplyStart else { return }
        didApplyStart = true
        guard let slug = startScreen else {
            stack = [entryScreen]
            return
        }
        switch slug {
        case "691-4822":
            stack = ["691-4767"]
            DispatchQueue.main.async { showDateSheet = true }
        case "691-5008":
            stack = ["691-5008"]
        case "691-5063":
            stack = ["691-5063"]
        default:
            stack = [entryScreen]
        }
    }
}

// MARK: - 2.1 / 2.2 · Item details

private struct RequestItemDetailsView: View {
    var item: Item
    var modalBackdrop: Bool
    var saved: Bool
    @Binding var photoPage: Int
    var onBack: () -> Void
    var onBorrowNow: () -> Void
    var onBorrowLater: () -> Void
    var onOwner: () -> Void
    var onHeart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if modalBackdrop {
                RQBigAppBar(title: "Item details", backAction: onBack)
            } else {
                BAppBar(
                    title: "Item description",
                    subtitle: "Need it Now · \(item.distance) away",
                    backAction: onBack
                )
            }

            ScrollView {
                if modalBackdrop {
                    modalContent
                } else {
                    standardContent
                }
            }
            .scrollIndicators(.hidden)

            actions
        }
    }

    // MARK: 2.1

    private var standardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                carousel(height: 145)
                pageDots
                titleRow(font: BFont.bold(22))
                descriptionText(size: 13)
                ownerCard
                pickupCard
                availabilityCard
            }
            depositChip
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, 8)
        .padding(.bottom, BSpace.xl)
    }

    private var pageDots: some View {
        HStack(spacing: 5) {
            ForEach(0..<item.photoCount, id: \.self) { index in
                Circle()
                    .fill(index == photoPage ? BColor.brand : Color.clear)
                    .overlay {
                        Circle().stroke(BColor.brand, lineWidth: index == photoPage ? 0 : 1)
                    }
                    .frame(width: 6, height: 6)
            }
            Text("· \(photoPage + 1) / \(item.photoCount)")
                .font(BFont.regular(11))
                .foregroundStyle(BColor.brand)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 15)
    }

    private var ownerCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                BAvatarView(photo: item.owner.photo, initials: item.owner.initials, size: 38)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(item.owner.name)
                            .font(BFont.bold(15))
                            .foregroundStyle(BColor.brand)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(BColor.brand)
                    }
                    Text("\(item.owner.credibility)/100 · \(item.owner.credibilityLabel)")
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)
                }
                Spacer(minLength: 0)
            }
            Text("Lender approval required · No instant booking")
                .font(BFont.regular(11))
                .foregroundStyle(BColor.inkSecondary)
        }
        .rqCard()
        .contentShape(Rectangle())
        .onTapGesture(perform: onOwner)
    }

    private var pickupCard: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Pickup · Block A Security Desk")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            Text("\(item.distance) away · Bencoolen")
                .font(BFont.regular(11))
                .foregroundStyle(BColor.inkSecondary)
        }
        .rqCard(padding: 10)
    }

    private var availabilityCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Availability · October 2026")
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            HStack(spacing: 8) {
                rangeBox("15–17 Oct · Busy", fill: RQPalette.busyFill, ink: BColor.inkSecondary)
                rangeBox("18–19 Oct · Free", fill: RQPalette.freeFill, ink: BColor.brand)
            }
        }
        .rqCard(padding: 10)
    }

    private func rangeBox(_ text: String, fill: Color, ink: Color) -> some View {
        Text(text)
            .font(BFont.regular(12))
            .foregroundStyle(ink)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var depositChip: some View {
        Text("Deposit: $\(Int(item.deposit))")
            .font(BFont.bold(16))
            .foregroundStyle(RQPalette.freeInk)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(RQPalette.freeFill)
            .clipShape(Capsule())
    }

    // MARK: 2.2 backdrop

    private var modalContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            carousel(height: 145)
            modalDots
            titleRow(font: BFont.bold(23))
            descriptionText(size: 14)

            HStack(alignment: .center) {
                Text("Deposit: $\(Int(item.deposit))")
                    .font(BFont.bold(11))
                    .foregroundStyle(RQPalette.freeInk)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(RQPalette.freeFill)
                    .clipShape(Capsule())
                Spacer()
                Text("Bencoolen St")
                    .font(BFont.regular(12))
                    .foregroundStyle(BColor.inkSecondary)
            }

            HStack(spacing: 10) {
                BAvatarView(photo: item.owner.photo, initials: item.owner.initials, size: 38)
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(item.owner.name) ✓")
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.brand)
                    Text("★ \(ratingText) · Credibility \(item.owner.credibility)/100 · \(item.owner.credibilityLabel)")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                }
                Spacer(minLength: 0)
                Text("View profile")
                    .font(BFont.bold(11))
                    .foregroundStyle(BColor.brand)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("October 2026 · Availability")
                    .font(BFont.bold(13))
                    .foregroundStyle(BColor.ink)
                HStack(spacing: 5) {
                    ForEach(15...21, id: \.self) { day in
                        let isFree = day >= 17
                        Text("\(day)")
                            .font(BFont.regular(12))
                            .foregroundStyle(isFree ? BColor.brand : BColor.inkSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .background(isFree ? RQPalette.freeFill : RQPalette.busyFill)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }
                Text("Grey dates are busy · View full calendar with Borrow Later")
                    .font(BFont.regular(10))
                    .foregroundStyle(BColor.inkSecondary)
            }
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, 8)
        .padding(.bottom, BSpace.xl)
    }

    private var modalDots: some View {
        HStack(spacing: 5) {
            Capsule().fill(BColor.brand).frame(width: 18, height: 5)
            Capsule().fill(RQPalette.dotInactive).frame(width: 5, height: 5)
            Capsule().fill(RQPalette.dotInactive).frame(width: 5, height: 5)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 5)
    }

    // MARK: Shared pieces

    private var ratingText: String {
        String(format: "%.1f", item.rating)
    }

    private func carousel(height: CGFloat) -> some View {
        TabView(selection: $photoPage) {
            ForEach(Array(item.allPhotos.enumerated()), id: \.offset) { index, photo in
                BImageView(photo: photo, cornerRadius: BRadius.photo)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.photo, style: .continuous))
    }

    private func titleRow(font: Font) -> some View {
        HStack(spacing: 10) {
            Text(item.title)
                .font(font)
                .foregroundStyle(BColor.ink)
            Spacer(minLength: 0)
            Button(action: onHeart) {
                Image(systemName: saved ? "heart.fill" : "heart")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(BColor.brand)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
        }
    }

    private func descriptionText(size: CGFloat) -> some View {
        Text(item.description)
            .font(BFont.regular(size))
            .foregroundStyle(BColor.inkSecondary)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var actions: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onBorrowNow) {
                    Text(modalBackdrop ? "⚡ Borrow Now" : "Borrow Now")
                        .font(BFont.bold(modalBackdrop ? 15 : 14))
                        .foregroundStyle(modalBackdrop ? BColor.ink : Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(modalBackdrop ? RQPalette.orangeAction : BColor.brand)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onBorrowLater) {
                    Text("Borrow Later")
                        .font(BFont.bold(modalBackdrop ? 15 : 14))
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
            .padding(.bottom, 18)
        }
        .background(BColor.bg)
    }
}

// MARK: - 2.3 · Request sent

private struct RequestSentView: View {
    var item: Item
    var onBack: () -> Void
    var onChat: () -> Void
    var onMyBorrowing: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(
                title: "Request sent",
                subtitle: "Borrow Now · Lender approval",
                backAction: onBack
            )

            ScrollView {
                VStack(spacing: 12) {
                    resultBlock
                    requestCard
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, BSpace.lg)
            }
            .scrollIndicators(.hidden)

            actions
        }
    }

    private var resultBlock: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(RQPalette.urgentFill)
                    .frame(width: 76, height: 76)
                Image(systemName: "clock")
                    .font(.system(size: 33, weight: .regular))
                    .foregroundStyle(RQPalette.urgentInk)
            }
            Text("Waiting for Thomas")
                .font(BFont.bold(24))
                .foregroundStyle(BColor.ink)
            Text("We’ll notify you when Thomas responds.")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 22)
    }

    private var requestCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            BImageView(photo: item.photo, cornerRadius: BRadius.photo)
                .frame(height: 110)
                .frame(maxWidth: .infinity)
            Text(item.title)
                .font(BFont.bold(19))
                .foregroundStyle(BColor.ink)
            RQStatusChip(text: "URGENT - Borrow Now", foreground: .white, background: BColor.brand)
            requestDetailRow("Borrower", "James")
            requestDetailRow("Lender", "Thomas")
            requestDetailRow("Requested dates", "18 → 19 Oct 2026")
            requestDetailRow("Duration", "1 day")
        }
        .rqCard()
    }

    private var actions: some View {
        VStack(spacing: 8) {
            Button(action: onChat) {
                Text("Chat with Thomas")
                    .font(BFont.bold(14))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(BColor.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button(action: onMyBorrowing) {
                Text("View My Borrowing")
                    .font(BFont.bold(14))
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
        .padding(.bottom, 18)
        .background(BColor.bg)
    }
}

/// "Borrower · James" style row used by 2.3 and 3.9.
private func requestDetailRow(_ label: String, _ value: String) -> some View {
    HStack(spacing: 0) {
        Text(label)
            .font(BFont.regular(13))
            .foregroundStyle(BColor.inkSecondary)
        Text("  ·  ")
            .font(BFont.regular(13))
            .foregroundStyle(BColor.inkSecondary)
        Text(value)
            .font(BFont.regular(13))
            .foregroundStyle(BColor.ink)
        Spacer(minLength: 0)
    }
    .frame(height: 24)
}

// MARK: - 2.4 · My Borrowing

private struct MyBorrowingContent: View {
    var onOpenBorrow: () -> Void

    @State private var pastSelected = false

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    toolbar
                    Text("Every borrow, from first hello to safe return.")
                        .font(BFont.regular(14))
                        .foregroundStyle(BColor.inkSecondary)
                    if pastSelected {
                        BEmptyState(
                            icon: "clock.arrow.circlepath",
                            title: "No past borrows",
                            message: "Finished borrows will appear here."
                        )
                    } else {
                        borrowCard
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, BSpace.xl)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            BLogoMark(width: 72)
            Text("My Borrowing")
                .font(BFont.bold(25))
                .foregroundStyle(BColor.ink)
                .lineLimit(1)
            Spacer(minLength: 0)
            Button {} label: {
                Image(systemName: "heart")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(BColor.brand)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BSpace.screen)
        .frame(height: BMetric.appBarHeight)
        .background(BColor.bg)
    }

    private var toolbar: some View {
        HStack(spacing: 18) {
            Button {
                withAnimation(.easeOut(duration: 0.15)) { pastSelected = false }
            } label: {
                Text("Active")
                    .font(BFont.bold(15))
                    .foregroundStyle(pastSelected ? BColor.inkSecondary : BColor.brand)
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.easeOut(duration: 0.15)) { pastSelected = true }
            } label: {
                Text("Past Borrow")
                    .font(BFont.bold(15))
                    .foregroundStyle(pastSelected ? BColor.brand : BColor.inkSecondary)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                Text("Sort / Filter")
                    .font(BFont.regular(12))
                    .foregroundStyle(BColor.brand)
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(BColor.ink)
            }
        }
        .frame(height: 19)
    }

    private var borrowCard: some View {
        Button(action: onOpenBorrow) {
            HStack(spacing: 12) {
                BImageView(photo: .steamer, cornerRadius: BRadius.photo)
                    .frame(width: 74, height: 80)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 5) {
                        Text("Garment Steamer")
                            .font(BFont.bold(14))
                            .foregroundStyle(BColor.ink)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(BColor.ink)
                    }
                    Text("Pick up: Sun 18 Oct, 7:30 pm · Block A Security Desk")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 5) {
                        // Figma fills this avatar with avatar_man2 in the 2.4 card.
                        BAvatarView(photo: BPhoto(key: "avatar_man2"), initials: "T", size: 19)
                        Text("Borrowed from Thomas")
                            .font(BFont.regular(11))
                            .foregroundStyle(BColor.ink)
                    }
                    RQStatusChip(text: "Pending")
                }
            }
            .rqCard(padding: 11)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Borro tab root (2.4 My Borrowing entry point)

struct MyBorrowingTabView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        MyBorrowingContent(onOpenBorrow: { router.push(.flow(.request, screen: "691-5008")) })
            .bBackground()
    }
}
