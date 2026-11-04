import SwiftUI

// Return — Figma section 7 · Return (node 703:2704)
//
// Artboards:
//   691-6651  7.1 James · Return code + after photos   (entry)
//   703-2705  7.2 Thomas · Enter borrower code
//   703-2785  7.3 Thomas · Return photo added
//   703-2867  7.4 Thomas · Ready to submit?           (sheet over 7.3)
//   691-6709  7.5 Both · Return confirmed
//   703-2954  7.6 Both · Timeline · refund processing

struct ReturnFlow: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: BorroStore

    var startScreen: String? = nil

    @State private var stack: [String] = []
    @State private var showReadySheet = false

    private let entry = "691-6651"
    private let known = ["691-6651", "703-2705", "703-2785", "703-2867", "691-6709", "703-2954"]

    var body: some View {
        ZStack {
            currentScreen
        }
        .bBackground()
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ReturnFlowTabBar(selected: selectedTab) { tab in
                router.switchTab(tab)
            }
        }
        .sheet(isPresented: $showReadySheet) {
            readySheet
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(BRadius.sheet)
                .presentationBackground(BColor.surface)
        }
        .onAppear(perform: applyStartScreen)
    }

    // MARK: - State machine

    private var current: String { stack.last ?? entry }

    private var selectedTab: AppTab {
        switch current {
        case "703-2705", "703-2785", "703-2867", "691-6709": return .lend
        default: return .borro
        }
    }

    private func go(_ slug: String) {
        withAnimation(.easeOut(duration: 0.2)) { stack.append(slug) }
    }

    private func back() {
        if stack.count > 1 {
            withAnimation(.easeOut(duration: 0.2)) { _ = stack.removeLast() }
        } else {
            router.pop()
        }
    }

    private func applyStartScreen() {
        guard stack.isEmpty else { return }
        guard let slug = startScreen else {
            stack = [entry]
            return
        }
        if slug == "703-2867" {
            // 7.4 is a sheet state: open its parent screen with the sheet up.
            stack = ["703-2785"]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                showReadySheet = true
            }
        } else if known.contains(slug) {
            stack = [slug]
        } else {
            stack = [entry]
        }
    }

    // MARK: - Screens

    @ViewBuilder
    private var currentScreen: some View {
        switch current {
        case "691-6651": jamesCodeScreen
        case "703-2705": thomasPhotoScreen(photoAdded: false)
        case "703-2785", "703-2867": thomasPhotoScreen(photoAdded: true)
        case "691-6709": confirmedScreen
        case "703-2954": timelineScreen
        default: jamesCodeScreen
        }
    }

    // MARK: 7.1 James · Return code + after photos

    private var jamesCodeScreen: some View {
        VStack(spacing: 0) {
            BAppBar(title: "Return handover", subtitle: "Block A Security Desk", backAction: back)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Garment Steamer")
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)

                    Text("James · Borrower shows code to Thomas")
                        .font(BFont.regular(12))
                        .foregroundStyle(BColor.inkSecondary)

                    returnCodeBlock

                    noticePanel(
                        title: "Meet in person first",
                        body: "Show this fresh return code to Thomas only when you meet in person. Thomas enters it on his phone to confirm the return."
                    )

                    Text("Photograph it as you leave it.")
                        .font(BFont.bold(17))
                        .foregroundStyle(BColor.ink)

                    HStack(alignment: .top, spacing: 12) {
                        afterPhotoTile("FRONT · ✓ Added")
                        afterPhotoTile("BACK · ✓ Added")
                    }

                    Button {
                        // Additional photo slots are optional; no extra artboard.
                    } label: {
                        Text("＋ ADDITIONAL · Optional")
                            .font(BFont.regular(12))
                            .foregroundStyle(BColor.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .background(BColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(BColor.stroke, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)

                    Text("Return · 19 Oct 2026 · 11:00 pm · Clear photos protect both of you. Front and back are required.")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)

            stickyAction("Confirm Return Drop-off") { go("703-2705") }
        }
    }

    private var returnCodeBlock: some View {
        VStack(spacing: 7) {
            HStack(spacing: 5) {
                Text("My Return Code")
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
                Image(systemName: "info.circle")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(BColor.ink)
            }

            ZStack {
                Circle()
                    .stroke(BColor.brand, lineWidth: 4)
                    .frame(width: 126, height: 126)
                VStack(spacing: 0) {
                    Text("8482")
                        .font(BFont.bold(29))
                        .foregroundStyle(BColor.ink)
                    Text("refreshes in 0:45")
                        .font(BFont.regular(13))
                        .foregroundStyle(BColor.inkSecondary)
                }
            }
            .frame(maxWidth: .infinity)

            Text("Refreshes every few minutes")
                .font(BFont.regular(11))
                .foregroundStyle(BColor.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private func afterPhotoTile(_ label: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            BPhotoTile(photo: .steamerShirt, height: 105)
            Text(label)
                .font(BFont.bold(11))
                .foregroundStyle(BColor.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: 7.2 / 7.3 Thomas · code + return photos

    private func thomasPhotoScreen(photoAdded: Bool) -> some View {
        VStack(spacing: 0) {
            BAppBar(title: "Return · Lender", subtitle: "Block A Security Desk", backAction: back)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Garment Steamer")
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)

                    VStack(spacing: 7) {
                        HStack(spacing: 5) {
                            Text("Enter borrower code")
                                .font(BFont.bold(14))
                                .foregroundStyle(BColor.ink)
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .foregroundStyle(BColor.ink)
                        }

                        borrowerCodeBoxes

                        Text("✓ Code verified · In-person handover")
                            .font(BFont.regular(11))
                            .foregroundStyle(BColor.inkSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)

                    Text("Photograph it as you collect it.")
                        .font(BFont.bold(17))
                        .foregroundStyle(BColor.ink)

                    Text("Clear photos protect both of you. Front and back are required.")
                        .font(BFont.regular(11))
                        .foregroundStyle(BColor.inkSecondary)

                    VStack(spacing: 8) {
                        VStack(spacing: 4) {
                            returnPhotoCard(photoAdded: photoAdded)
                            HStack(spacing: 6) {
                                Text(photoAdded ? "Left · Steamer" : "FRONT · Required")
                                    .font(BFont.bold(11))
                                    .foregroundStyle(BColor.ink)
                                if photoAdded {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(BColor.ink)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        stepControls

                        Color.clear.frame(height: 28)
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)

            stickyAction("Confirm Collection", enabled: photoAdded) {
                guard photoAdded else { return }
                showReadySheet = true
            }
        }
    }

    private var borrowerCodeBoxes: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                Text(String(Array("8482")[index]))
                    .font(BFont.bold(26))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 58, height: 60)
                    .background(BColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(BColor.brand, lineWidth: 1.5)
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func returnPhotoCard(photoAdded: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if photoAdded {
                    BImageView(photo: .steamer, cornerRadius: 10)
                } else {
                    BColor.surface
                }
            }
            .frame(height: 210)
            .frame(maxWidth: .infinity)

            if photoAdded {
                Button {
                    // Photo options live in the handover flow; no artboard here.
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(BColor.brand)
                        .frame(width: 27, height: 27)
                        .background(BColor.surface)
                        .clipShape(Circle())
                        .overlay { Circle().stroke(BColor.brand, lineWidth: 2) }
                }
                .buttonStyle(.plain)
                .padding(10)
            } else {
                Button {
                    go("703-2785")
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.system(size: 21, weight: .medium))
                            .foregroundStyle(BColor.brand)
                        Text("Add photo")
                            .font(BFont.bold(15))
                            .foregroundStyle(BColor.brand)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    Color(hex: 0xACACAC),
                    style: StrokeStyle(lineWidth: 1, dash: [6, 5])
                )
        }
    }

    private var stepControls: some View {
        HStack(spacing: 12) {
            Button {
                // Single recorded condition; the carousel is decorative here.
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(BColor.inkSecondary)
                    .frame(width: 24, height: 24)
                    .background(BColor.surfaceAlt)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    stepPill(index)
                }
            }

            Button {
                // Single recorded condition; the carousel is decorative here.
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(BColor.inkSecondary)
                    .frame(width: 24, height: 24)
                    .background(BColor.surfaceAlt)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private func stepPill(_ index: Int) -> some View {
        let done = showReadySheet
        let filled = showReadySheet || current == "703-2785"
        let background: Color = done ? BColor.success : (filled ? BColor.brand : BColor.surfaceAlt)
        let number: Color = (done || filled) ? .white : BColor.inkSecondary
        return ZStack {
            Circle().fill(background)
            Text("\(index + 1)")
                .font(BFont.bold(12))
                .foregroundStyle(number)
        }
        .frame(width: 24, height: 24)
        .overlay {
            if index == 0 && !filled {
                Circle().stroke(BColor.brand, lineWidth: 2)
            }
        }
    }

    // MARK: 7.4 Ready to submit? (sheet)

    private var readySheet: some View {
        BSheetSurface {
            VStack(alignment: .leading, spacing: 13) {
                Text("Ready to submit?")
                    .font(BFont.bold(20))
                    .foregroundStyle(BColor.ink)

                Text("Your collection code and required front/back photos are ready.")
                    .font(BFont.regular(15))
                    .foregroundStyle(BColor.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text("These condition records protect both members. Check that the photos are clear.")
                    .font(BFont.regular(13))
                    .foregroundStyle(BColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                ReturnFlowActionButton(title: "Go back and review", primary: false) {
                    showReadySheet = false
                }

                ReturnFlowActionButton(title: "Confirm submission") {
                    showReadySheet = false
                    go("691-6709")
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    // MARK: 7.5 Both · Return confirmed

    private var confirmedScreen: some View {
        VStack(spacing: 0) {
            BAppBar(title: "Return · Lender", subtitle: "Block A Security Desk", backAction: back)

            ScrollView {
                VStack(spacing: 12) {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(BColor.brand, lineWidth: 3)
                                .frame(width: 70, height: 70)
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(BColor.brand)
                        }

                        Text("Return confirmed")
                            .font(BFont.bold(27))
                            .foregroundStyle(BColor.ink)

                        Text("Both sides’ return records are saved.")
                            .font(BFont.regular(16))
                            .foregroundStyle(BColor.inkSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 26)
                    .padding(.bottom, 12)

                    VStack(spacing: 10) {
                        BImageView(photo: .steamer, cornerRadius: 10)
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)

                        detailRow("Condition photos", "Front ✓ · Back ✓")
                        detailRow("Time", "19 Oct · 11:00 pm")
                    }
                    .padding(12)
                    .background(BColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                            .stroke(BColor.stroke, lineWidth: 0.7)
                    }

                    noticePanel(
                        title: "Return record saved",
                        body: "Your $10 deposit will be refunded automatically."
                    )
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)

            stickyAction("View return status") { go("703-2954") }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 10) {
            Text(label)
                .font(BFont.regular(14))
                .foregroundStyle(BColor.inkSecondary)
            Spacer(minLength: 0)
            Text(value)
                .font(BFont.semibold(14))
                .foregroundStyle(BColor.ink)
        }
        .frame(height: 26)
    }

    // MARK: 7.6 Both · Timeline · refund processing

    private var timelineScreen: some View {
        VStack(spacing: 0) {
            BAppBar(title: "Timeline", subtitle: "Garment Steamer · BR-20481", backAction: back)

            ScrollView {
                VStack(spacing: 10) {
                    milestoneStrip

                    HStack(spacing: 12) {
                        BImageView(photo: .steamer, cornerRadius: 10)
                            .frame(width: 78, height: 68)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Garment Steamer")
                                .font(BFont.bold(18))
                                .foregroundStyle(BColor.ink)
                            Text("Completed")
                                .font(BFont.bold(18))
                                .foregroundStyle(BColor.ink)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(BColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                            .stroke(BColor.stroke, lineWidth: 0.7)
                    }

                    HStack(spacing: 10) {
                        BAvatarView(photo: BPeople.thomas.photo, initials: BPeople.thomas.initials, size: 38)
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 5) {
                                Text("Thomas")
                                    .font(BFont.bold(15))
                                    .foregroundStyle(BColor.ink)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(BColor.ink)
                            }
                            HStack(spacing: 4) {
                                Text("★")
                                    .font(BFont.bold(15))
                                    .foregroundStyle(BColor.ink)
                                Text("5.0 · 10 reviews")
                                    .font(BFont.bold(15))
                                    .foregroundStyle(BColor.ink)
                            }
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

                    handoverDetailsCard

                    outlineAction("View Agreement") {
                        router.push(.flow(.agreement, screen: "691-5763"))
                    }
                    outlineAction("Before / After · View condition photos") {
                        router.push(.flow(.handover, screen: nil))
                    }

                    HStack {
                        Text("Deposit Status · Refund processing")
                            .font(BFont.bold(14))
                            .foregroundStyle(BColor.ink)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(BColor.successSoft)
                    .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, BSpace.screen)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)

            HStack(spacing: 10) {
                ReturnFlowActionButton(title: "View borrowing summary", fullWidth: false) {
                    router.switchTab(.borro)
                }
                .frame(width: 223)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
    }

    private var milestoneStrip: some View {
        HStack(spacing: 6) {
            ForEach(["Agreed", "Meet-up", "Lending", "Return"], id: \.self) { label in
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(BColor.brand)
                        .frame(height: 4)
                    Text(label)
                        .font(BFont.semibold(10))
                        .foregroundStyle(BColor.ink)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 31, alignment: .top)
    }

    private var handoverDetailsCard: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                Text("Pickup").foregroundStyle(BColor.inkSecondary)
                Text("·").foregroundStyle(BColor.inkSecondary)
                Text("18 Oct · 7:30 pm").foregroundStyle(BColor.ink).fontWeight(.semibold)
            }
            HStack(spacing: 5) {
                Text("Return").foregroundStyle(BColor.inkSecondary)
                Text("·").foregroundStyle(BColor.inkSecondary)
                Text("19 Oct · 11:00 pm").foregroundStyle(BColor.ink).fontWeight(.semibold)
            }
            HStack(spacing: 5) {
                Image(systemName: "scope")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(BColor.ink)
                Text("Block A Security Desk")
                    .foregroundStyle(BColor.ink)
                    .fontWeight(.semibold)
            }
        }
        .font(BFont.regular(14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 0.7)
        }
    }

    // MARK: - Shared pieces

    private func noticePanel(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: "info.circle")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(BColor.ink)
                Text(title)
                    .font(BFont.bold(14))
                    .foregroundStyle(BColor.ink)
            }
            Text(body)
                .font(BFont.regular(13))
                .foregroundStyle(BColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(BColor.successSoft)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }

    private func outlineAction(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
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

    private func stickyAction(_ title: String, enabled: Bool = true, action: @escaping () -> Void) -> some View {
        ReturnFlowActionButton(title: title, enabled: enabled, action: action)
            .padding(.horizontal, BSpace.screen)
            .padding(.top, 10)
            .padding(.bottom, 18)
    }
}

// MARK: - Local components

private struct ReturnFlowActionButton: View {
    var title: String
    var enabled: Bool = true
    var primary: Bool = true
    var height: CGFloat = 48
    var fullWidth: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BFont.bold(15))
                .foregroundStyle(foreground)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.horizontal, fullWidth ? 0 : 20)
                .frame(height: height)
                .background(background)
                .clipShape(Capsule())
                .overlay {
                    if !primary {
                        Capsule().stroke(BColor.brand, lineWidth: 1.2)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private var foreground: Color {
        if !primary { return BColor.brand }
        return enabled ? .white : BColor.inkSecondary
    }

    private var background: Color {
        if !primary { return BColor.surface }
        return enabled ? BColor.brand : BColor.surfaceAlt
    }
}

private struct ReturnFlowTabBar: View {
    var selected: AppTab
    var onSelect: (AppTab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(BColor.stroke)
                .frame(height: 1)
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
