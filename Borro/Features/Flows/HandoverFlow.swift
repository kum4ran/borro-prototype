import SwiftUI

// Handover — Figma sections 6 · Handover (codes + photos), 6b · Photo steps, 6c · Timeline
//
// Artboards
//  6.1  691-6129  lender drop-off code          6.2  703-434   lender code info (sheet)
//  6.3  704-166   name the photo (sheet)        6.3a 736-170   name the back photo (sheet)
//  6.3b 736-486   name the extra photo (sheet)  6.4  704-484   front photo added
//  6.5  704-792   back photo (empty)            6.5a 736-804   back photo added
//  6.6  703-765   add additional photos         6.6a 736-1115  extra photo added
//  6.7  703-1074  photo options                 6.8  703-1403  edit photo name (sheet)
//  6.9  703-1718  ready to submit? (sheet)      6.10 703-2035  drop-off saved
//  6.11 691-6435  enter lender code             6.12 703-2090  wrong code
//  6.13 703-2171  meet in person first (sheet)  6.14 703-2262  code verified
//  6.14a-d 736-1432 / 736-1533 / 736-1634 / 736-1738 · collection photo states
//  6.15 703-2430  photo added                   6.16 703-2512  photo options
//  6.17 703-2342  missing photos (sheet)        6.18 703-2615  ready to submit (sheet)
//  6.19 691-6511  handover summary              6.20 691-6585  timeline · ongoing
//  6.10a 739-311  timeline · meet-up            5.7  739-225   timeline · agreed
//  7.2a-d 736-1844 / 736-1945 / 736-2046 / 736-2150 · return photo-step states in 6b
//
// Every slug renders its own artboard, so `startScreen` deep-links work.

// MARK: - Flow

struct HandoverFlow: View {
    @EnvironmentObject private var router: AppRouter

    var startScreen: String? = nil

    @State private var stack: [String] = []

    private let entry = "691-6129"

    var body: some View {
        ZStack {
            screen(for: current)
        }
        .bBackground()
        .onAppear {
            if stack.isEmpty { stack = [startScreen ?? entry] }
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

    @ViewBuilder
    private func screen(for slug: String) -> some View {
        switch slug {
        case "691-6129", "703-434", "704-166", "736-170", "736-486",
             "704-484", "704-792", "736-804", "703-765", "736-1115",
             "703-1074", "703-1403", "703-1718":
            DropOffPhotoScreen(slug: slug, back: back, go: go)

        case "703-2035":
            DropOffSavedScreen(back: back, go: go)

        case "691-6435", "703-2090", "703-2171", "703-2262",
             "736-1432", "736-1533", "736-1634", "736-1738",
             "703-2342", "703-2430", "703-2512", "703-2615":
            CollectionScreen(slug: slug, back: back, go: go)

        case "691-6511":
            HandoverSummaryScreen(back: back, go: go)

        case "691-6585", "739-225", "739-311":
            HandoverTimelineScreen(slug: slug, back: back, go: go)

        case "736-1844", "736-1945", "736-2046", "736-2150":
            ReturnPhotoStepScreen(slug: slug, back: back)

        default:
            DropOffPhotoScreen(slug: "691-6129", back: back, go: go)
        }
    }
}

// MARK: - Shared small pieces

private struct HandoverInfoDot: View {
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(BColor.inkSecondary)
                .frame(width: 16, height: 16)
        }
        .buttonStyle(.plain)
    }
}

private struct PhotoStepPill: View {
    var number: Int
    var state: Int   // 0 locked · 1 current (ring) · 2 filled · 3 complete (green)

    var body: some View {
        ZStack {
            Circle()
                .fill(fill)
                .frame(width: 24, height: 24)
            if state == 1 {
                Circle()
                    .stroke(BColor.brand, lineWidth: 2)
                    .frame(width: 24, height: 24)
            }
            Text("\(number)")
                .font(BFont.bold(12))
                .foregroundStyle(state == 2 || state == 3 ? .white : BColor.inkSecondary)
        }
        .frame(width: 24, height: 24)
    }

    private var fill: Color {
        switch state {
        case 2: return BColor.brand
        case 3: return BHandoverTone.greenText
        default: return BHandoverTone.control
        }
    }
}

private struct PhotoCarouselChevron: View {
    var systemName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(BColor.inkSecondary)
                .frame(width: 24, height: 24)
                .background(BHandoverTone.control)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

/// The "photograph it" block shared by the drop-off, collection and return
/// photo-step screens: active photo card, label row, carousel pills.
private struct PhotoRecordsBlock: View {
    var photos: [BPhoto?]          // front, back, extra
    var extraLabel: String?
    var active: Int
    var pills: [Int]
    var showsExtraSection: Bool

    var onAdd: (Int) -> Void
    var onPencil: () -> Void
    var onMore: () -> Void
    var onPill: (Int) -> Void
    var onStep: (Int) -> Void

    private var activePhoto: BPhoto? {
        guard active >= 0, active < photos.count else { return nil }
        return photos[active]
    }

    private var addLabel: String {
        active == 2 ? "Add Additional Photos" : "Add photo"
    }

    private var requirementLabel: String {
        switch active {
        case 0: return "FRONT · Required"
        case 1: return "BACK · Required"
        default: return extraLabel ?? "POSITION · Edit"
        }
    }

    private var showsPencil: Bool {
        activePhoto != nil || active == 2
    }

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                photoBox
                labelRow
            }
            carousel
            if showsExtraSection {
                Spacer().frame(height: 28)
            }
        }
    }

    private var photoBox: some View {
        ZStack(alignment: .topTrailing) {
            if let activePhoto {
                BImageView(photo: activePhoto, cornerRadius: 10)
                    .frame(height: 210)
                    .frame(maxWidth: .infinity)
                Button(action: onMore) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(BColor.brand)
                        .frame(width: 27, height: 27)
                        .background(BColor.surface)
                        .clipShape(Circle())
                        .overlay { Circle().stroke(BColor.brand, lineWidth: 2) }
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
                .padding(.trailing, 6)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                        .fill(BColor.surface)
                        .overlay {
                            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                                .strokeBorder(
                                    Color(hex: 0xACACAC),
                                    style: StrokeStyle(lineWidth: 1, dash: [5, 4])
                                )
                        }
                    Button {
                        onAdd(active)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "icloud.and.arrow.up")
                                .font(.system(size: 21, weight: .medium))
                                .foregroundStyle(BColor.brand)
                            Text(addLabel)
                                .font(BFont.bold(15))
                                .foregroundStyle(BColor.brand)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 210)
            }
        }
    }

    private var labelRow: some View {
        HStack(spacing: 6) {
            Text(requirementLabel)
                .font(BFont.microBold)
                .foregroundStyle(BColor.ink)
            if showsPencil {
                Button(action: onPencil) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color(hex: 0x1E1E1E))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 26)
    }

    private var carousel: some View {
        HStack(spacing: 12) {
            PhotoCarouselChevron(systemName: "chevron.left") { onStep(-1) }
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Button {
                        onPill(index)
                    } label: {
                        PhotoStepPill(number: index + 1, state: pillState(index))
                    }
                    .buttonStyle(.plain)
                }
            }
            PhotoCarouselChevron(systemName: "chevron.right") { onStep(1) }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 24)
    }

    private func pillState(_ index: Int) -> Int {
        index < pills.count ? pills[index] : 0
    }
}

/// The floating iOS-style photo action menu.
private struct PhotoOptionsMenu: View {
    var onDelete: () -> Void
    var onUpload: () -> Void
    var onTake: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            option(icon: "trash", title: "Delete Photo", tint: Color(hex: 0xFF383C), action: onDelete)
            option(icon: "photo", title: "Upload New Photo", tint: Color(hex: 0x1A1A1A), action: onUpload)
            option(icon: "camera", title: "Take New Photo", tint: Color(hex: 0x1A1A1A), action: onTake)
        }
        .frame(width: 250)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .bShadow(2)
    }

    private func option(icon: String, title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .regular))
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 17, weight: .regular))
                Spacer(minLength: 0)
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 26)
            .frame(height: 42)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 6.1 – 6.9 lender drop-off (code + photo steps)

private enum DropOffSheet {
    case codeInfo
    case namePhoto(initial: String)
    case editName(initial: String)
    case ready
}

private struct DropOffPhotoScreen: View {
    var slug: String
    var back: () -> Void
    var go: (String) -> Void

    @State private var nameDraft: String = ""

    private var front: Bool {
        ["704-484", "704-792", "736-804", "703-765", "736-1115",
         "703-1074", "703-1403", "703-1718", "704-166", "736-170", "736-486"].contains(slug)
    }

    private var backAdded: Bool {
        ["736-804", "703-765", "736-1115", "704-166", "736-170", "736-486"].contains(slug)
    }

    private var extraAdded: Bool { slug == "736-1115" }

    private var active: Int {
        switch slug {
        case "704-792", "736-804": return 1
        case "703-765", "736-1115", "704-166", "736-170", "736-486": return 2
        default: return 0
        }
    }

    private var pills: [Int] {
        switch slug {
        case "691-6129": return [1, 0, 0]
        case "704-484", "703-1074", "703-1403", "703-1718": return [2, 0, 0]
        case "704-792": return [2, 1, 0]
        case "736-804": return [2, 2, 0]
        case "703-765": return [2, 2, 1]
        case "736-1115": return [2, 2, 2]
        case "704-166", "736-170", "736-486": return [0, 0, 1]
        default: return [1, 0, 0]
        }
    }

    private var sheet: DropOffSheet? {
        switch slug {
        case "703-434": return .codeInfo
        case "704-166", "736-170": return .namePhoto(initial: "")
        case "736-486": return .namePhoto(initial: "Left · Steamer")
        case "703-1403": return .editName(initial: "Right Side - steamer")
        case "703-1718": return .ready
        default: return nil
        }
    }

    private var menuOpen: Bool { slug == "703-1074" }

    private var photos: [BPhoto?] {
        [
            front ? .steamerShirt : nil,
            backAdded ? .steamerShirt : nil,
            extraAdded ? .steamer : nil
        ]
    }

    private var canConfirm: Bool { front && backAdded }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
            BAppBar(title: "Drop-off", subtitle: "Block A Security Desk", showsBack: true, backAction: back)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Garment Steamer")
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)
                    lenderCodeBlock
                    Text("Photograph it as you leave it.")
                        .font(BFont.bold(17))
                        .foregroundStyle(BColor.ink)
                    photoRecords
                    Text("Clear photos protect both of you. Front and back are required.")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            Button {
                if canConfirm { go("703-1718") }
            } label: {
                Text("Confirm Drop-off")
            }
            .buttonStyle(BHandoverActionStyle(kind: canConfirm ? .primary : .disabled))
            .disabled(!canConfirm)
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)

            }
            sheetOverlay
            }
            BHandoverNavBar(active: .lend)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear { syncDraft() }
        .onChange(of: slug) { _, _ in syncDraft() }
    }

    private func syncDraft() {
        switch sheet {
        case .namePhoto(let initial), .editName(let initial): nameDraft = initial
        default: nameDraft = ""
        }
    }

    // MARK: code

    private var lenderCodeBlock: some View {
        VStack(spacing: 7) {
            HStack(spacing: 4) {
                Text("My Lender Code")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
                HandoverInfoDot { go("703-434") }
            }
            .frame(height: 19)

            ZStack {
                Circle().fill(BColor.surface)
                Circle().stroke(BColor.brand, lineWidth: 4)
                VStack(spacing: 0) {
                    Text("6767")
                        .font(BFont.bold(29))
                        .foregroundStyle(BColor.ink)
                    Text("refreshes in 0:45")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                }
            }
            .frame(width: 126, height: 126)

            HStack(spacing: 4) {
                Text("Refreshes every few minutes")
                    .font(BFont.regular(11))
                    .foregroundStyle(BColor.inkSecondary)
                Image(systemName: "info.circle")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(BColor.inkSecondary)
            }
            .frame(height: 15)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: photos

    private var photoRecords: some View {
        ZStack(alignment: .topLeading) {
            PhotoRecordsBlock(
                photos: photos,
                extraLabel: extraAdded ? "Left · Steamer" : nil,
                active: active,
                pills: pills,
                showsExtraSection: true,
                onAdd: { index in
                    switch index {
                    case 0: go("704-484")
                    case 1: go("736-170")
                    default: go("704-166")
                    }
                },
                onPencil: { go("703-1403") },
                onMore: { go("703-1074") },
                onPill: { index in
                    switch index {
                    case 0: go(front ? "704-484" : "691-6129")
                    case 1: go("704-792")
                    default: go("703-765")
                    }
                },
                onStep: { delta in
                    let next = min(2, max(0, active + delta))
                    switch next {
                    case 0: go(front ? "704-484" : "691-6129")
                    case 1: go("704-792")
                    default: go("703-765")
                    }
                }
            )

            if menuOpen {
                PhotoOptionsMenu(
                    onDelete: { go("691-6129") },
                    onUpload: { go("704-166") },
                    onTake: { go("704-166") }
                )
                .padding(.leading, 100)
                .offset(y: 6)
            }
        }
    }

    // MARK: sheets

    @ViewBuilder
    private var sheetOverlay: some View {
        if let sheet {
            ZStack(alignment: .bottom) {
                BHandoverSheetScrim(onTap: { dismiss(sheet) })
                switch sheet {
                case .codeInfo:
                    BHandoverSheetSurface(horizontalPadding: 20, topPadding: 40, bottomPadding: 20, spacing: 15, handleTop: 9) {
                        codeInfoSheet
                    }
                case .namePhoto:
                    BHandoverSheetSurface(background: BHandoverTone.sheetGrey, horizontalPadding: 20, topPadding: 40, bottomPadding: 20, spacing: 15, handleTop: 9) {
                        nameSheet(title: "Name of picture", placeholder: "Example: Left Side  - speaker", confirmTitle: "Confirm upload", cancelTitle: "Cancel Upload")
                    }
                case .editName:
                    BHandoverSheetSurface(background: BHandoverTone.sheetGrey, horizontalPadding: 20, topPadding: 40, bottomPadding: 20, spacing: 15, handleTop: 9) {
                        nameSheet(title: "Edit Name", placeholder: "", confirmTitle: "Confirm edit", cancelTitle: "Cancel edit", tall: true)
                    }
                case .ready:
                    BHandoverSheetSurface(horizontalPadding: 20, topPadding: 40, bottomPadding: 13, spacing: 15, handleTop: 9) {
                        readySheet
                    }
                }
            }
        }
    }

    private var codeInfoSheet: some View {
        VStack(alignment: .leading, spacing: 15) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(BColor.brand)
                .frame(width: 36, height: 42, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text("My lender code ")
                    .font(BFont.bold(20))
                    .foregroundStyle(BColor.ink)
                Text("Meet In Person First")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.brand)
            }
            Text("Show this code to the borrower only when you meet in person. They enter it on their phone to confirm the handover.")
                .font(BFont.regular(15))
                .foregroundStyle(BColor.ink)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                go("691-6129")
            } label: {
                Text("Got it")
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))
        }
    }

    private func nameSheet(title: String, placeholder: String, confirmTitle: String, cancelTitle: String, tall: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(BFont.bold(20))
                .foregroundStyle(BColor.ink)
            TextField(placeholder, text: $nameDraft, axis: .vertical)
                .font(BFont.regular(15))
                .foregroundStyle(BColor.ink)
                .lineLimit(3)
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: (tall || nameDraft.isEmpty) ? 84 : 44, alignment: .topLeading)
                .background(BColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                        .stroke(BColor.stroke, lineWidth: 0.7)
                }
            Button {
                go("703-765")
            } label: {
                Text(cancelTitle)
            }
            .buttonStyle(BHandoverActionStyle(kind: .outline))
            Button {
                go("736-1115")
            } label: {
                Text(confirmTitle)
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))
        }
    }

    private var readySheet: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ready to submit?")
                .font(BFont.bold(20))
                .foregroundStyle(BColor.ink)
            Text("Your drop-off code and required front/back photos are ready.")
                .font(BFont.regular(15))
                .foregroundStyle(BColor.ink)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
            Text("These condition records protect both members. Check that the photos are clear.")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .lineSpacing(1.2)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                go("736-1115")
            } label: {
                Text("Go back and review")
            }
            .buttonStyle(BHandoverActionStyle(kind: .outline))
            Button {
                go("703-2035")
            } label: {
                Text("Confirm submission")
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))
        }
    }

    private func dismiss(_ sheet: DropOffSheet) {
        switch sheet {
        case .codeInfo: go("691-6129")
        case .namePhoto: go("703-765")
        case .editName: go("704-484")
        case .ready: go("736-1115")
        }
    }
}

// MARK: - 6.10 Drop-off saved

private struct DropOffSavedScreen: View {
    var back: () -> Void
    var go: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(title: "Drop-off saved", subtitle: "Block A Security Desk · BR-20481", showsBack: true, backAction: back)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    successHeading
                    summaryCard
                    notice(
                        title: "✓ Before photos recorded",
                        body: "Both of you can see them in the timeline."
                    )
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            Button {
                go("691-6435")
            } label: {
                Text("Hand over to James")
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)

            BHandoverNavBar(active: .lend)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private var successHeading: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(BHandoverTone.greenTint).frame(width: 74, height: 74)
                Image(systemName: "checkmark")
                    .font(.system(size: 31, weight: .semibold))
                    .foregroundStyle(BColor.brand)
            }
            Text("Before photos saved")
                .font(BFont.bold(24))
                .foregroundStyle(BColor.ink)
            Text("Ask James to enter your lender code on his phone to collect the steamer.")
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
            detail("Borrower  ·  James", tint: BColor.inkSecondary)
            detail("Lender  ·  Thomas", tint: BColor.inkSecondary)
            detail("Pickup  ·  18 Oct · 7:30 pm", tint: BColor.ink)
            detail("Return  ·  19 Oct · 11:00 pm", tint: BColor.ink)
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

    private func detail(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(BFont.regular(13))
            .foregroundStyle(tint)
            .frame(height: 24, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func notice(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            Text(body)
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .lineSpacing(1.2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BHandoverTone.greenTint)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }
}

// MARK: - 6.11 – 6.18 borrower collection

private enum CollectionSheet {
    case meetInPerson
    case missingPhotos
    case ready
}

private struct CollectionScreen: View {
    var slug: String
    var back: () -> Void
    var go: (String) -> Void

    private var digits: String {
        switch slug {
        case "691-6435": return ""
        case "703-2090", "703-2171": return "1234"
        default: return "6767"
        }
    }

    private var verified: Bool {
        !["691-6435", "703-2090", "703-2171"].contains(slug)
    }

    private var wrong: Bool {
        ["703-2090", "703-2171"].contains(slug)
    }

    private var front: Bool {
        ["736-1432", "736-1533", "736-1634", "736-1738",
         "703-2342", "703-2430", "703-2512", "703-2615"].contains(slug)
    }

    private var backAdded: Bool {
        ["736-1634", "736-1738", "703-2342", "703-2430", "703-2512", "703-2615"].contains(slug)
    }

    private var extraAdded: Bool {
        ["703-2342", "703-2430", "703-2512", "703-2615"].contains(slug)
    }

    private var active: Int {
        switch slug {
        case "736-1533": return 1
        case "736-1738", "703-2342", "703-2430", "703-2512", "703-2615": return 2
        default: return 0
        }
    }

    private var pills: [Int] {
        switch slug {
        case "691-6435", "703-2090", "703-2171": return [2, 0, 0]
        case "703-2262": return [1, 0, 0]
        case "736-1432": return [2, 0, 0]
        case "736-1533": return [2, 1, 0]
        case "736-1634": return [2, 2, 0]
        case "736-1738": return [2, 2, 1]
        case "703-2342", "703-2615": return [3, 3, 3]
        case "703-2430", "703-2512": return [2, 2, 2]
        default: return [2, 0, 0]
        }
    }

    private var photos: [BPhoto?] {
        [
            front ? .steamerShirt : nil,
            backAdded ? .steamerShirt : nil,
            extraAdded ? .steamer : nil
        ]
    }

    private var sheet: CollectionSheet? {
        switch slug {
        case "703-2171": return .meetInPerson
        case "703-2342": return .missingPhotos
        case "703-2615": return .ready
        default: return nil
        }
    }

    private var menuOpen: Bool { slug == "703-2512" }

    private var canConfirm: Bool { verified && front && backAdded }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
            BAppBar(title: "Collection", subtitle: "Block A Security Desk", showsBack: true, backAction: back)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Garment Steamer")
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)
                    codeBlock
                    if !verified {
                        Text(wrong
                             ? "ⓘ Please key in the correct lender code."
                             : "ⓘ A code is required before you can confirm collection.")
                            .font(BFont.regular(13))
                            .foregroundStyle(BHandoverTone.red)
                    }
                    Text("Photograph it as you collect it.")
                        .font(BFont.bold(17))
                        .foregroundStyle(BColor.ink)
                    Text("Clear photos protect both of you. Front and back are required.")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                    photoRecords
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            Button {
                if verified {
                    go(front && backAdded ? "703-2615" : "703-2342")
                }
            } label: {
                Text("Confirm Collection")
            }
            .buttonStyle(BHandoverActionStyle(kind: canConfirm ? .primary : .disabled))
            .disabled(!canConfirm)
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)

            }
            sheetOverlay
            }
            BHandoverNavBar(active: .borro)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    // MARK: code entry

    private var codeBlock: some View {
        VStack(spacing: 7) {
            HStack(spacing: 4) {
                Text("Enter lender code")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
                HandoverInfoDot { go("703-2171") }
            }
            .frame(height: 19)
            .padding(.vertical, 19)

            CodeDigitRow(digits: digits, verified: verified, wrong: wrong)
                .onTapGesture {
                    if digits.isEmpty {
                        go("703-2090")
                    } else if wrong {
                        go("703-2262")
                    }
                }

            Group {
                if verified {
                    Text("✓ Code verified · In-person handover")
                        .foregroundStyle(BColor.inkSecondary)
                } else {
                    Text("Please enter the 4-digit code from your lender.")
                        .foregroundStyle(BHandoverTone.muted)
                }
            }
            .font(BFont.regular(11))
            .frame(height: 15)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: photos

    private var photoRecords: some View {
        ZStack(alignment: .topLeading) {
            PhotoRecordsBlock(
                photos: photos,
                extraLabel: extraAdded ? "Left · Steamer" : nil,
                active: active,
                pills: pills,
                showsExtraSection: true,
                onAdd: { index in
                    guard verified else { return }
                    switch index {
                    case 0: go("736-1432")
                    case 1: go("736-1634")
                    default: go("703-2430")
                    }
                },
                onPencil: { if verified { go("703-2512") } },
                onMore: { if verified { go("703-2512") } },
                onPill: { index in
                    guard verified else { return }
                    switch index {
                    case 0: go("736-1432")
                    case 1: go("736-1533")
                    default: go("736-1738")
                    }
                },
                onStep: { delta in
                    guard verified else { return }
                    let next = min(2, max(0, active + delta))
                    switch next {
                    case 0: go("736-1432")
                    case 1: go("736-1533")
                    default: go("736-1738")
                    }
                }
            )

            if menuOpen {
                PhotoOptionsMenu(
                    onDelete: { go("736-1533") },
                    onUpload: { go("703-2430") },
                    onTake: { go("703-2430") }
                )
                .padding(.leading, 100)
                .offset(y: 6)
            }
        }
    }

    // MARK: sheets

    @ViewBuilder
    private var sheetOverlay: some View {
        if let sheet {
            ZStack(alignment: .bottom) {
                BHandoverSheetScrim(onTap: { dismiss(sheet) })
                switch sheet {
                case .meetInPerson:
                    BHandoverSheetSurface(horizontalPadding: 20, topPadding: 40, bottomPadding: 13, spacing: 13, handleTop: 9) {
                        meetSheet
                    }
                case .missingPhotos:
                    BHandoverSheetSurface(horizontalPadding: 20, topPadding: 40, bottomPadding: 20, spacing: 13, handleTop: 9) {
                        missingSheet
                    }
                case .ready:
                    BHandoverSheetSurface(horizontalPadding: 20, topPadding: 40, bottomPadding: 13, spacing: 15, handleTop: 9) {
                        readySheet
                    }
                }
            }
        }
    }

    private var meetSheet: some View {
        VStack(alignment: .leading, spacing: 13) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(BColor.brand)
                .frame(width: 36, height: 42, alignment: .leading)
            Text("Meet in person first")
                .font(BFont.bold(20))
                .foregroundStyle(BColor.ink)
            Text("Ask your lender to show their code when you meet in person. Enter the 4-digit code on your phone to confirm the handover.")
                .font(BFont.regular(15))
                .foregroundStyle(BColor.ink)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
            Text("Never ask for, share or enter a meet-up code remotely.")
                .font(BFont.regular(14))
                .foregroundStyle(BHandoverTone.red)
                .lineSpacing(1.2)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                go("703-2090")
            } label: {
                Text("Got it")
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))
        }
    }

    private var missingSheet: some View {
        VStack(alignment: .leading, spacing: 13) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(BColor.brand)
                .frame(width: 36, height: 42, alignment: .leading)
            Text("Missing photos")
                .font(BFont.bold(20))
                .foregroundStyle(BColor.ink)
            Text("There is an incomplete upload for your collection")
                .font(BFont.regular(15))
                .foregroundStyle(BHandoverTone.red)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
            Text("Remember to always take clear picture so that lenders are able to assess the quality clearly")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .lineSpacing(1.2)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                go("703-2430")
            } label: {
                Text("Got it")
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))
        }
    }

    private var readySheet: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ready to submit?")
                .font(BFont.bold(20))
                .foregroundStyle(BColor.ink)
            Text("Your collection code and required front/back photos are ready.")
                .font(BFont.regular(15))
                .foregroundStyle(BColor.ink)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
            Text("These condition records protect both members. Check that the photos are clear.")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .lineSpacing(1.2)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                go("703-2430")
            } label: {
                Text("Go back and review")
            }
            .buttonStyle(BHandoverActionStyle(kind: .outline))
            Button {
                go("691-6511")
            } label: {
                Text("Confirm submission")
            }
            .buttonStyle(BHandoverActionStyle(kind: .primary))
        }
    }

    private func dismiss(_ sheet: CollectionSheet) {
        switch sheet {
        case .meetInPerson: go("703-2090")
        case .missingPhotos: go("703-2430")
        case .ready: go("703-2430")
        }
    }
}

/// 4-digit code boxes: 58x60, r10, 40pt digits, red while unverified.
private struct CodeDigitRow: View {
    var digits: String
    var verified: Bool
    var wrong: Bool

    private var stroke: Color {
        verified ? BColor.brand : BHandoverTone.red
    }

    private var digitColor: Color {
        wrong ? BHandoverTone.redText : BColor.ink
    }

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(BColor.surface)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(stroke, lineWidth: 1.5)
                    digit(at: index)
                }
                .frame(width: 58, height: 60)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func digit(at index: Int) -> some View {
        let chars = Array(digits)
        if index < chars.count {
            Text(String(chars[index]))
                .font(BFont.bold(40))
                .foregroundStyle(digitColor)
        }
    }
}

// MARK: - 6.19 Handover summary

private struct HandoverSummaryScreen: View {
    var back: () -> Void
    var go: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(title: "Handover summary", subtitle: "Garment Steamer · BR-20481", showsBack: true, backAction: back)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    notice("✓ Both confirmed", "Thomas and James confirmed the in-person collection.")
                    summaryCard
                    conditionCard
                    notice("Deposit · $10 · Held safely", "Held securely by Borro until the steamer is successfully returned.")
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            Button {
                go("691-6585")
            } label: {
                Text("View Timeline")
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

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                BImageView(photo: .steamer, cornerRadius: 10)
                    .frame(width: 80, height: 83)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Garment Steamer")
                        .font(BFont.bold(19))
                        .foregroundStyle(BColor.ink)
                    Text("Thomas → James")
                        .font(BFont.regular(13))
                        .foregroundStyle(BColor.ink)
                    Text("Ongoing")
                        .font(BFont.bold(11))
                        .foregroundStyle(BColor.brand)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: 0xEAF0FF))
                        .clipShape(Capsule())
                }
                Spacer(minLength: 0)
            }
            Text("Pickup  ·  18 Oct 2026 · 7:30 pm")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.ink)
                .frame(height: 24, alignment: .leading)
            Text("Return  ·  19 Oct 2026 · 11:00 pm")
                .font(BFont.regular(13))
                .foregroundStyle(BColor.ink)
                .frame(height: 24, alignment: .leading)
            Text("Block A Security Desk")
                .font(BFont.regular(11))
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

    private var conditionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Condition records · Both confirmed")
                .font(BFont.bold(15))
                .foregroundStyle(BColor.ink)
            memberRecord(name: "Thomas · ✓ Submitted", time: "18 Oct · 7:28 pm")
            memberRecord(name: "James · ✓ Submitted", time: "18 Oct · 7:31 pm")
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

    private func memberRecord(name: String, time: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(BFont.bold(13))
                    .foregroundStyle(.black)
                Spacer(minLength: 0)
                Text(time)
                    .font(BFont.regular(10))
                    .foregroundStyle(BColor.inkSecondary)
            }
            .frame(height: 16)
            HStack(spacing: 10) {
                BImageView(photo: .steamer, cornerRadius: 10)
                    .frame(width: 159, height: 70)
                BImageView(photo: .steamerShirt, cornerRadius: 10)
                    .frame(width: 159, height: 70)
            }
            Text("FRONT ✓ · BACK ✓")
                .font(BFont.regular(10))
                .foregroundStyle(BColor.inkSecondary)
                .frame(height: 14, alignment: .leading)
        }
    }

    private func notice(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(BFont.bold(14))
                .foregroundStyle(BColor.ink)
            Text(body)
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .lineSpacing(1.2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BHandoverTone.greenTint)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }
}

// MARK: - 6.20 / 6.10a / 5.7 Timeline

private struct HandoverTimelineScreen: View {
    var slug: String
    var back: () -> Void
    var go: (String) -> Void

    @EnvironmentObject private var router: AppRouter

    private var stageIndex: Int {
        switch slug {
        case "739-225": return 0
        case "739-311": return 1
        default: return 2
        }
    }

    private var status: String {
        switch slug {
        case "739-225": return "Handover pending"
        case "739-311": return "Meet-up in progress"
        default: return "Ongoing"
        }
    }

    private var footnote: String {
        switch slug {
        case "739-225": return "Agreement signed and deposit paid. Meet Thomas at Block A Security Desk on Sun 18 Oct, 7:30 pm."
        case "739-311": return "Thomas has dropped off the steamer. James enters the lender code to collect it."
        default: return "Handover confirmed by James and Thomas. Let the steamer cool, empty the tank and return the mitt."
        }
    }

    private var actionTitle: String {
        switch slug {
        case "739-225": return "Go to handover"
        case "739-311": return "Collect steamer"
        default: return "Ready to Return"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(title: "Timeline", subtitle: "Garment Steamer · BR-20481", showsBack: true, backAction: back)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    progress
                    itemCard
                    memberRow
                    detailsCard
                    Button {
                        go("691-6511")
                    } label: {
                        Text("View Agreement")
                    }
                    .buttonStyle(BHandoverActionStyle(kind: .outline))
                    Button {
                        go("691-6511")
                    } label: {
                        Text("Before / After · View condition photos")
                    }
                    .buttonStyle(BHandoverActionStyle(kind: .outline))
                    depositNotice
                    Text(footnote)
                        .font(BFont.regular(12))
                        .foregroundStyle(BColor.inkSecondary)
                        .lineSpacing(1.5)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            HStack(spacing: 10) {
                Button {
                    primaryAction()
                } label: {
                    Text(actionTitle)
                }
                .buttonStyle(BHandoverActionStyle(kind: .primary))
                .frame(width: 223)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)

            BHandoverNavBar(active: .borro)
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private func primaryAction() {
        switch slug {
        case "739-225": go("691-6129")
        case "739-311": go("691-6435")
        default: router.push(.flow(.returnFlow, screen: nil))
        }
    }

    private var progress: some View {
        let labels = ["Agreed", "Meet-up", "Lending", "Return"]
        return HStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { index in
                VStack(spacing: 5) {
                    Capsule()
                        .fill(index <= stageIndex ? BColor.brand : BColor.stroke)
                        .frame(height: 4)
                    Text(labels[index])
                        .font(index == stageIndex ? BFont.microBold : BFont.microSemibold)
                        .foregroundStyle(index <= stageIndex ? BColor.ink : BColor.inkSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 31)
    }

    private var itemCard: some View {
        HStack(spacing: 12) {
            BImageView(photo: .steamer, cornerRadius: 10)
                .frame(width: 78, height: 68)
            VStack(alignment: .leading, spacing: 0) {
                Text("Garment Steamer")
                Text(status)
            }
            .font(BFont.bold(18))
            .foregroundStyle(BColor.ink)
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
        .bShadow(1)
    }

    private var memberRow: some View {
        HStack(spacing: 10) {
            BAvatarView(photo: .thomas, initials: "TL", size: 38)
            VStack(alignment: .leading, spacing: 2) {
                Text("Thomas ✓")
                    .font(BFont.bold(15))
                    .foregroundStyle(BColor.ink)
                Text("★ 5.0 · 10 reviews")
                    .font(BFont.semibold(11))
                    .foregroundStyle(BColor.ink)
            }
            Spacer(minLength: 0)
            Button {
                go("691-6511")
            } label: {
                Text("View profile")
                    .font(BFont.bold(11))
                    .foregroundStyle(BColor.brand)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 38)
    }

    private var detailsCard: some View {
        Text("Pickup  ·  18 Oct · 7:30 pm\nReturn  ·  19 Oct · 11:00 pm\n⌖ Block A Security Desk")
            .font(BFont.regular(14))
            .foregroundStyle(BColor.ink)
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
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

    private var depositNotice: some View {
        Text("Deposit Status · Held safely")
            .font(BFont.bold(14))
            .foregroundStyle(BColor.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BHandoverTone.greenTint)
            .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }
}

// MARK: - 6b · 7.2a-d Return · Lender photo steps

private struct ReturnPhotoStepScreen: View {
    var slug: String
    var back: () -> Void

    @EnvironmentObject private var router: AppRouter
    @State private var override: String? = nil

    private var effective: String { override ?? slug }

    private var front: Bool { true }
    private var backAdded: Bool { ["736-2046", "736-2150"].contains(effective) }

    private var active: Int {
        switch effective {
        case "736-1945", "736-2046": return 1
        case "736-2150": return 2
        default: return 0
        }
    }

    private var pills: [Int] {
        switch effective {
        case "736-1844": return [2, 0, 0]
        case "736-1945": return [2, 1, 0]
        case "736-2046": return [2, 2, 0]
        default: return [2, 2, 1]
        }
    }

    private var photos: [BPhoto?] {
        [
            front ? .steamerShirt : nil,
            backAdded ? .steamerShirt : nil,
            nil
        ]
    }

    private var canConfirm: Bool { front && backAdded }

    var body: some View {
        VStack(spacing: 0) {
            BAppBar(title: "Return · Lender", subtitle: "Block A Security Desk", showsBack: true, backAction: back)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Garment Steamer")
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)
                    borrowerCodeBlock
                    Text("Photograph it as you collect it.")
                        .font(BFont.bold(17))
                        .foregroundStyle(BColor.ink)
                    Text("Clear photos protect both of you. Front and back are required.")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                    PhotoRecordsBlock(
                        photos: photos,
                        extraLabel: nil,
                        active: active,
                        pills: pills,
                        showsExtraSection: false,
                        onAdd: { index in
                            if index == 1 { setState("736-2046") }
                        },
                        onPencil: {},
                        onMore: {},
                        onPill: { index in
                            switch index {
                            case 0: setState("736-1844")
                            case 1: setState("736-1945")
                            default: setState("736-2150")
                            }
                        },
                        onStep: { delta in
                            let next = min(2, max(0, active + delta))
                            switch next {
                            case 0: setState("736-1844")
                            case 1: setState("736-1945")
                            default: setState("736-2150")
                            }
                        }
                    )
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 18)
            }

            Button {
                if canConfirm { router.push(.flow(.returnFlow, screen: nil)) }
            } label: {
                Text("Confirm Collection")
            }
            .buttonStyle(BHandoverActionStyle(kind: canConfirm ? .primary : .disabled))
            .disabled(!canConfirm)
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
            .background(BColor.bg)

            BHandoverNavBar(active: .lend)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onChange(of: slug) { _, _ in override = nil }
    }

    private func setState(_ value: String) {
        withAnimation(.easeOut(duration: 0.2)) { override = value }
    }

    private var borrowerCodeBlock: some View {
        VStack(spacing: 7) {
            HStack(spacing: 4) {
                Text("Enter borrower code")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
                Image(systemName: "info.circle")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(BColor.inkSecondary)
                    .frame(width: 16, height: 16)
            }
            .frame(height: 19)
            .padding(.vertical, 19)

            CodeDigitRow(digits: "8482", verified: true, wrong: false)
            Text("✓ Code verified · In-person handover")
                .font(BFont.regular(11))
                .foregroundStyle(BColor.inkSecondary)
                .frame(height: 15)
        }
        .frame(maxWidth: .infinity)
    }
}
