import SwiftUI

// MARK: - Section 4 · Schedule and chat (Figma node 701:202)
//
// 14 artboards, all reachable from the flow and deep-linkable via `-uiScreen`:
//
//   701-203  4.1  James · Propose handover
//   701-284  4.2  James · Pick-up dates        (sheet over 4.1)
//   701-429  4.3  James · Pick-up times        (sheet over 4.1)
//   701-585  4.4  James · Return dates         (sheet over 4.1)
//   701-762  4.5  James · Return times         (sheet over 4.1)
//   701-951  4.6  James · Pick on map          (sheet over 4.1)
//   701-1059 4.7  James · Times chosen
//   701-1177 4.8  James · Proposal sent
//   691-5576 4.9  James · Chat with Thomas
//   701-1267 4.10 James · Chat attachment menu (sheet over 4.9)
//   701-1366 4.11 Thomas · Review proposal
//   701-1464 4.12 Thomas · Choose times        (sheet over 4.11)
//   701-1626 4.13 Thomas · Request changes     (branch state)
//   701-1718 4.14 Both · Handover confirmed
//
// Every screen is an iPhone frame 393 x 852. The body draws in a coordinate
// space that ignores the safe area and re-applies the status-bar height at the
// top, so the Figma vertical rhythm is preserved 1:1 on device.

// MARK: - Section 4 palette (values read from the Figma nodes; local to this file)

private enum S4 {
    static let bg = Color(hex: 0xF7F8F6)
    static let bgAlt = Color(hex: 0xF6F6F3)
    static let surface = Color.white

    static let ink = Color(hex: 0x14231C)
    static let inkDeep = Color(hex: 0x12201A)
    static let inkDark = Color(hex: 0x162C32)
    static let inkSecondary = Color(hex: 0x68766E)
    static let inkMuted = Color(hex: 0x5E6561)
    static let inkTertiary = Color(hex: 0x708187)

    static let brand = Color(hex: 0x2340D9)
    static let brandDeep = Color(hex: 0x1B33B8)
    static let brandSend = Color(hex: 0x283DE3)
    static let brandStroke = Color(hex: 0x3D49FF)
    static let brandChip = Color(hex: 0xE7EAFB)
    static let brandChipAlt = Color(hex: 0xE8EAFF)
    static let brandChipInk = Color(hex: 0x233BDE)

    static let muted = Color(hex: 0xEEEFEB)
    static let pillGrey = Color(hex: 0xEEEEE9)
    static let stroke = Color(hex: 0xE5E8E3)
    static let strokeField = Color(hex: 0xD1D6DB)
    static let strokeLight = Color(hex: 0xDADDDC)
    static let strokeIcon = Color(hex: 0xE2E8E1)
    static let divider = Color(hex: 0xE4E4DF)
    static let sheetGrabber = Color(hex: 0xB9BCBF)
    static let scrim = Color(hex: 0x12201A)

    static let disabledFill = Color(hex: 0xDADDDC)
    static let disabledInk = Color(hex: 0x4A524F)
    static let disabledInk2 = Color(hex: 0x6B726E)

    static let greenSoft = Color(hex: 0xE8F4EC)
    static let greenBanner = Color(hex: 0xE4F2EC)
    static let greenInk = Color(hex: 0x0B6B4F)
    static let greenText = Color(hex: 0x3E4642)
    static let greenLabel = Color(hex: 0x1E8E5A)

    static let orangeText = Color(hex: 0xB05C14)

    static let calInk = Color(hex: 0x23272F)
    static let calMuted = Color(hex: 0x8B8E95)
    static let borrowerCell = Color(hex: 0xFBF8E4)
    static let borrowerCellSel = Color(hex: 0xFBF3D4)
    static let lenderCell = Color(hex: 0xFCEADC)
    static let borrowerKey = Color(hex: 0xFBEFCC)
    static let lenderKey = Color(hex: 0xFCE3D0)

    static let mapBg = Color(hex: 0xE8EEE4)
    static let mapBlock1 = Color(hex: 0xD8E1D3)
    static let mapBlock2 = Color(hex: 0xD5DFCF)
    static let mapAmber = Color(hex: 0xFBF3D4)
    static let mapAmberStroke = Color(hex: 0xD8C16A)
    static let mapOrange = Color(hex: 0xFCEADC)
    static let mapOrangeStroke = Color(hex: 0xE2A57B)
    static let pinAmber = Color(hex: 0xB8951F)
    static let pinOrange = Color(hex: 0xD2773A)
    static let helperAmber = Color(hex: 0x7A5A00)
    static let helperOrange = Color(hex: 0x8A4A1C)
}

// MARK: - Flow sheets (artboards that are pop-ups)

private enum S4Sheet {
    case pickupDates
    case pickupTimes
    case returnDates
    case returnTimes
    case map
    case attachment
    case chooseTimes
}

// MARK: - Flow

struct ScheduleChatFlow: View {
    @EnvironmentObject private var router: AppRouter

    var startScreen: String? = nil

    @State private var stack: [String] = []

    // James ↔ Thomas proposal state
    @State private var pickupChosen = false
    @State private var returnChosen = false
    @State private var meetingAddress: String? = nil

    // Thomas's side
    @State private var thomasPickup: String? = nil
    @State private var thomasReturn: String? = nil

    // Chat composer
    @State private var chatDraft = ""

    private let entrySlug = "701-203"

    private static let allSlugs: Set<String> = [
        "701-203", "701-284", "701-429", "701-585", "701-762", "701-951",
        "701-1059", "701-1177", "691-5576", "701-1267", "701-1366",
        "701-1464", "701-1626", "701-1718"
    ]

    var body: some View {
        GeometryReader { proxy in
            let top = proxy.safeAreaInsets.top == 0 ? 59 : proxy.safeAreaInsets.top
            ZStack(alignment: .bottom) {
                baseScreen(top: top)
                sheetLayer(top: top)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
        .ignoresSafeArea()
        .background(S4.bg.ignoresSafeArea())
        .onAppear(perform: applyStartScreen)
    }

    // MARK: Navigation

    private var current: String { stack.last ?? entrySlug }

    private var baseSlug: String {
        switch current {
        case "701-284", "701-429", "701-585", "701-762", "701-951":
            return "701-203"
        case "701-1267":
            return "691-5576"
        case "701-1464":
            return "701-1366"
        default:
            return current
        }
    }

    private var activeSheet: S4Sheet? {
        switch current {
        case "701-284": return .pickupDates
        case "701-429": return .pickupTimes
        case "701-585": return .returnDates
        case "701-762": return .returnTimes
        case "701-951": return .map
        case "701-1267": return .attachment
        case "701-1464": return .chooseTimes
        default: return nil
        }
    }

    private func go(_ slug: String) {
        withAnimation(.easeOut(duration: 0.22)) { stack.append(slug) }
    }

    private func back() {
        if stack.count > 1 {
            withAnimation(.easeOut(duration: 0.22)) { _ = stack.removeLast() }
        } else {
            router.pop()
        }
    }

    // MARK: Deep links

    private func applyStartScreen() {
        guard stack.isEmpty else { return }
        let slug = (startScreen.flatMap { Self.allSlugs.contains($0) ? $0 : nil }) ?? entrySlug
        configureState(for: slug)
        stack = [slug]
    }

    private func configureState(for slug: String) {
        pickupChosen = false
        returnChosen = false
        meetingAddress = nil
        thomasPickup = nil
        thomasReturn = nil

        switch slug {
        case "701-585", "701-762":
            pickupChosen = true
            meetingAddress = "Block A Security Desk"
        case "701-1059", "701-1177", "691-5576", "701-1267":
            pickupChosen = true
            returnChosen = true
            meetingAddress = "Block A Security Desk"
        case "701-1366", "701-1464", "701-1626":
            pickupChosen = true
            returnChosen = true
            meetingAddress = "Block A Security Desk"
        case "701-1718":
            pickupChosen = true
            returnChosen = true
            meetingAddress = "Block A Security Desk"
            thomasPickup = "7:30 pm"
            thomasReturn = "11:00 pm"
        default:
            break
        }
    }

    // MARK: Base screens

    @ViewBuilder
    private func baseScreen(top: CGFloat) -> some View {
        switch baseSlug {
        case "701-1177":
            proposalSentScreen(top: top)
        case "691-5576":
            chatScreen(top: top)
        case "701-1366":
            reviewProposalScreen(top: top)
        case "701-1626":
            requestChangesScreen(top: top)
        case "701-1718":
            handoverConfirmedScreen(top: top)
        default:
            proposeHandoverScreen(top: top)
        }
    }

    /// Standard screen chrome: status-bar spacer, then the screen's content.
    private func screen<Content: View>(
        top: CGFloat,
        bg: Color = S4.bg,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: .top) {
            bg
            VStack(spacing: 0) {
                Color.clear.frame(height: top)
                content()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// The 78pt in-flow tab bar every artboard in this section shows.
    private var tabBar: some View {
        BTabBar(selection: Binding(
            get: { router.tab },
            set: { router.switchTab($0) }
        ))
        .padding(.top, 2)
        .padding(.bottom, 11)
        .background(S4.surface)
    }

    // MARK: - 4.1 Propose handover (also 4.4/4.5/4.7 states)

    private var isReviewForm: Bool {
        pickupChosen || returnChosen || meetingAddress != nil
    }

    @ViewBuilder
    private func proposeHandoverScreen(top: CGFloat) -> some View {
        if isReviewForm {
            reviewFormScreen(top: top)
        } else {
            editFormScreen(top: top)
        }
    }

    private func editFormScreen(top: CGFloat) -> some View {
        screen(top: top) {
            BAppBar(
                title: "Arrange handover",
                subtitle: "Thomas · Garment Steamer",
                backAction: back
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("A convenient place. A time that works for both.")
                        .font(BFont.regular(14))
                        .foregroundStyle(S4.inkSecondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    editSelectionCard
                        .padding(.horizontal, 16)
                        .padding(.top, 7)

                    meetingDetailsBlock(compact: false)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 0) {
                Text("Choose a meeting address and time to continue.")
                    .font(BFont.regular(11))
                    .foregroundStyle(S4.inkTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .frame(height: 15)
                Spacer().frame(height: 5)
                S4ActionButton(title: "Send Proposal", enabled: false, titleColor: S4.disabledInk) {}
                    .padding(.horizontal, 16)
                Spacer().frame(height: 6)
                tabBar
            }
        }
    }

    private var editSelectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pick-up")
                .font(BFont.bold(15))
                .foregroundStyle(S4.inkDark)

            Button { go("701-284") } label: {
                selectRow(title: "Select date and time", enabled: true)
            }
            .buttonStyle(.plain)

            Text("Return")
                .font(BFont.bold(15))
                .foregroundStyle(S4.inkDark)

            selectRow(title: "Select date and time", enabled: false)

            Text("Choose pick-up first. Return times open up after\nit.")
                .font(BFont.regular(14))
                .foregroundStyle(S4.inkTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(S4.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(S4.stroke, lineWidth: 1)
        }
    }

    private func selectRow(title: String, enabled: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(S4.brandStroke)
                .frame(width: 20, height: 20)
            Text(title)
                .font(BFont.medium(16))
                .foregroundStyle(enabled ? S4.inkDark : S4.inkTertiary)
            Spacer(minLength: 0)
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(S4.inkTertiary)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 66)
        .background(enabled ? S4.surface : S4.muted)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            if enabled {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(S4.strokeField, lineWidth: 1)
            }
        }
    }

    // MARK: 4.7 / 4.4 / 4.5 parent — completed form

    private func reviewFormScreen(top: CGFloat) -> some View {
        let complete = returnChosen
        let helper = complete
            ? "Thomas’s preferred spot is Block A Security Desk."
            : "Your preferred spot will be shared with Thomas."
        let helperTint = complete ? S4.orangeText : S4.inkTertiary

        return screen(top: top) {
            BAppBar(
                title: "Arrange handover",
                subtitle: "Thomas · Garment Steamer",
                backAction: back
            )

            ScrollView {
                VStack(spacing: 12) {
                    S4AvailabilityCard(
                        title: "Pick-up",
                        countText: "2 times",
                        date: "Sun 18 Oct",
                        times: ["7 pm", "7:30 pm"],
                        collapsed: false
                    ) {
                        go("701-284")
                    }

                    S4AvailabilityCard(
                        title: "Return",
                        countText: returnChosen ? "3 times" : nil,
                        date: "Mon 19 Oct",
                        times: ["10 pm", "11 pm", "11:30 pm"],
                        collapsed: !returnChosen
                    ) {
                        if pickupChosen { go("701-585") }
                    }

                    meetingDetailsBlock(compact: true)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 0) {
                Text(helper)
                    .font(BFont.regular(11))
                    .foregroundStyle(helperTint)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .frame(height: 15)
                Spacer().frame(height: 8)
                S4ActionButton(
                    title: "Send Proposal",
                    enabled: pickupChosen,
                    fill: S4.brandSend,
                    titleColor: S4.disabledInk
                ) {
                    if pickupChosen { go("701-1177") }
                }
                .padding(.horizontal, 16)
                Spacer().frame(height: 6)
                tabBar
            }
        }
    }

    private func meetingDetailsBlock(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Meeting address")
                    .font(BFont.bold(15))
                    .foregroundStyle(S4.inkDark)

                Button { go("701-951") } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(S4.inkDark)
                            .frame(width: 20, height: 20)
                        Text(meetingAddress ?? "Not set yet")
                            .font(meetingAddress == nil ? BFont.medium(15) : BFont.medium(14))
                            .foregroundStyle(meetingAddress == nil ? S4.inkTertiary : S4.inkDark)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(S4.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(compact ? S4.strokeField : S4.strokeLight, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }

            Button { go("701-951") } label: {
                Text("Pick on map")
                    .font(BFont.bold(15))
                    .foregroundStyle(S4.brandStroke)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(S4.surface)
                    .clipShape(Capsule())
                    .overlay { Capsule().stroke(S4.brandStroke, lineWidth: 1.7) }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 4.8 Proposal sent

    private func proposalSentScreen(top: CGFloat) -> some View {
        screen(top: top, bg: S4.bgAlt) {
            compactHeader(title: "Proposal sent", subtitle: "James & Thomas · Garment Steamer")

            ScrollView {
                VStack(spacing: 12) {
                    S4Banner(
                        icon: "clock",
                        tint: S4.greenInk,
                        title: "Waiting for Thomas",
                        message: "Thomas will pick one pick-up and one return time from the options you offered.",
                        height: 82
                    )
                    BImageView(photo: .steamer, cornerRadius: 10)
                        .frame(height: 125)
                        .frame(maxWidth: .infinity)
                    S4DetailsCard(
                        pickup: "Sun 18 Oct · 7, 7:30 pm",
                        returnTime: "Mon 19 Oct · 10, 11, 11:30 pm",
                        meetAt: "Block A Security Desk"
                    )
                    S4PersonRow(
                        photo: .thomas,
                        initials: "T",
                        initialsTint: S4.brandDeep,
                        initialsBackground: S4.brandChip,
                        avatarSize: 38,
                        name: "Thomas",
                        rating: "★ 5.0 · 10 reviews",
                        actionTitle: "View profile",
                        onSelect: { go("691-5576") }
                    ) {
                        router.push(.person(BPeople.thomas))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 0) {
                S4ActionButton(title: "Edit proposal") { go("701-1059") }
                    .padding(.horizontal, 16)
                    .padding(.top, 13)
                    .padding(.bottom, 16)
                tabBar
            }
            .background(S4.bgAlt)
            .overlay(alignment: .top) { Rectangle().fill(S4.divider).frame(height: 1) }
        }
    }

    // MARK: - 4.9 Chat with Thomas

    private var chatMessages: [ChatMessage] {
        let reply = current == "701-1267"
            ? "Sure, see you at the security desk!"
            : "Sure, see you there! I’ll return it tomorrow by 11 pm."
        return [
            ChatMessage(id: "c1",
                        text: "Hi James! Meet at Block A Security Desk at 7:30 pm for the steamer?",
                        isMine: false, time: "6:42 pm"),
            ChatMessage(id: "c2", text: reply, isMine: true, time: "6:43 pm"),
            ChatMessage(id: "c3",
                        text: "Lovely, please take a look at this agreement!",
                        isMine: false, time: "6:44 pm")
        ]
    }

    private func chatScreen(top: CGFloat) -> some View {
        screen(top: top) {
            BAppBar(
                title: "Thomas",
                subtitle: "★ 5.0 · 10 reviews",
                backAction: back
            )

            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(current == "701-1267" ? "18 October 2026" : "18 OCTOBER 2026")
                            .font(BFont.regular(11))
                            .foregroundStyle(S4.inkSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)

                        ForEach(chatMessages) { message in
                            S4ChatBubbleRow(message: message)
                        }

                        S4AgreementCard { go("701-1366") }

                        HStack(spacing: 7) {
                            quickReply("On my way")
                            quickReply("Thanks")
                            quickReply("See you soon")
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                .scrollIndicators(.hidden)

                S4BorroChatButton()
                    .padding(.trailing, 20)
                    .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity)

            VStack(spacing: 0) {
                S4Composer(text: $chatDraft) {
                    go("701-1267")
                } onSend: {
                    chatDraft = ""
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 18)
            .padding(.horizontal, 20)

            tabBar
        }
    }

    private func quickReply(_ text: String) -> some View {
        Text(text)
            .font(BFont.bold(11))
            .foregroundStyle(S4.greenLabel)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(S4.greenSoft)
            .clipShape(Capsule())
    }

    // MARK: - 4.11 Thomas · Review proposal

    private func reviewProposalScreen(top: CGFloat) -> some View {
        screen(top: top, bg: S4.bgAlt) {
            compactHeader(title: "Review proposal", subtitle: "James & Thomas · Garment Steamer")

            ScrollView {
                VStack(spacing: 12) {
                    S4Banner(
                        icon: "clock",
                        tint: S4.greenInk,
                        title: "James is waiting for you",
                        message: "James sent you a proposal. Pick one pick-up and one return time to accept.",
                        height: 82
                    )
                    BImageView(photo: .steamer, cornerRadius: 10)
                        .frame(height: 81)
                        .frame(maxWidth: .infinity)
                    S4DetailsCard(
                        pickup: "Sun 18 Oct · 7, 7:30 pm",
                        returnTime: "Mon 19 Oct · 10, 11, 11:30 pm",
                        meetAt: "Block A Security Desk"
                    )
                    S4PersonRow(
                        photo: nil,
                        initials: "J",
                        initialsTint: S4.brandDeep,
                        initialsBackground: S4.brandChip,
                        avatarSize: 40,
                        name: "James",
                        rating: "★ 3.5 · 45 reviews",
                        actionTitle: "View profile",
                        onSelect: { router.push(.person(BPeople.james)) }
                    ) {
                        router.push(.person(BPeople.james))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    S4OutlineButton(title: "Request changes") { go("701-1626") }
                    S4OutlineButton(title: "Chat with James", icon: "bubble.left") {
                        go("691-5576")
                    }
                }
                S4ActionButton(title: "Accept proposal") { go("701-1464") }
            }
            .padding(.horizontal, 16)
            .padding(.top, 11)
            .padding(.bottom, 12)
            .background(S4.bgAlt)
            .overlay(alignment: .top) { Rectangle().fill(S4.divider).frame(height: 1) }

            tabBar
        }
    }

    // MARK: - 4.13 Thomas · Request changes (branch)

    private func requestChangesScreen(top: CGFloat) -> some View {
        screen(top: top) {
            BAppBar(
                title: "Request changes",
                subtitle: "James · Garment Steamer",
                backAction: back
            )

            ScrollView {
                VStack(spacing: 12) {
                    VStack(spacing: 10) {
                        S4MatchRow(
                            title: "Pick-up · 2026",
                            count: "2 times",
                            date: "Sun 18 Oct",
                            times: ["7 pm", "7:30 pm"],
                            summary: "2 selected · 2 match James"
                        )
                        S4MatchRow(
                            title: "Return · 2026",
                            count: "1 time",
                            date: "Mon 19 Oct",
                            times: ["11 pm"],
                            summary: "1 selected · 1 match James"
                        )
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(S4.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(S4.stroke, lineWidth: 1)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 7) {
                            Text("Meeting address")
                                .font(BFont.bold(15))
                                .foregroundStyle(S4.inkDark)
                            Button { go("701-951") } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundStyle(S4.inkDark)
                                        .frame(width: 20, height: 20)
                                    Text(meetingAddress ?? "Block A Security Desk")
                                        .font(BFont.medium(14))
                                        .foregroundStyle(S4.inkDark)
                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(S4.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(S4.strokeField, lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        Button { go("701-951") } label: {
                            Text("Pick on map")
                                .font(BFont.bold(15))
                                .foregroundStyle(S4.brandStroke)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(S4.surface)
                                .clipShape(Capsule())
                                .overlay { Capsule().stroke(S4.brandStroke, lineWidth: 1.7) }
                        }
                        .buttonStyle(.plain)
                    }

                    S4PreferredSpotCard()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 0) {
                Text("Your preferred spot will be shared with James.")
                    .font(BFont.regular(11))
                    .foregroundStyle(S4.inkTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .frame(height: 15)
                Spacer().frame(height: 8)
                S4ActionButton(title: "Send Changes", fill: S4.brandSend) {
                    withAnimation(.easeOut(duration: 0.25)) { stack = ["701-1177"] }
                }
                .padding(.horizontal, 16)
                Spacer().frame(height: 6)
                tabBar
            }
        }
    }

    // MARK: - 4.14 Both · Handover confirmed

    private func handoverConfirmedScreen(top: CGFloat) -> some View {
        let pickupLabel = "Sun 18 Oct · " + (thomasPickup ?? "7:30 pm")
        let returnLabel = "Mon 19 Oct · " + (thomasReturn ?? "11:00 pm")

        return screen(top: top, bg: S4.bgAlt) {
            compactHeader(title: "Handover confirmed", subtitle: "James & Thomas · Garment Steamer")

            ScrollView {
                VStack(spacing: 12) {
                    S4Banner(
                        icon: "checkmark",
                        tint: S4.greenInk,
                        title: "Both confirmed",
                        message: "Thomas and James confirmed this arrangement.",
                        height: 64
                    )
                    BImageView(photo: .steamer, cornerRadius: 10)
                        .frame(height: 125)
                        .frame(maxWidth: .infinity)
                    S4DetailsCard(
                        pickup: pickupLabel,
                        returnTime: returnLabel,
                        meetAt: "Block A Security Desk"
                    )
                    S4PersonRow(
                        photo: .thomas,
                        initials: "T",
                        initialsTint: S4.brandDeep,
                        initialsBackground: S4.brandChip,
                        avatarSize: 38,
                        name: "Thomas",
                        rating: "★ 5.0 · 10 reviews",
                        actionTitle: "View profile"
                    ) {
                        router.push(.person(BPeople.thomas))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 10) {
                S4OutlineButton(title: "Chat with Thomas", height: 48, radius: 24, fontSize: 15) {
                    go("691-5576")
                }
                S4ActionButton(title: "View Final Agreement", height: 48, font: BFont.semibold(15)) {
                    go("701-1366")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 13)
            .padding(.bottom, 16)
            .background(S4.bgAlt)
            .overlay(alignment: .top) { Rectangle().fill(S4.divider).frame(height: 1) }

            tabBar
        }
    }

    private func compactHeader(title: String, subtitle: String) -> some View {
        HStack(spacing: 4) {
            Button { back() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(S4.inkDeep)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BFont.bold(20))
                    .foregroundStyle(S4.inkDeep)
                Text(subtitle)
                    .font(BFont.regular(12))
                    .foregroundStyle(S4.inkMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .frame(height: 56)
    }

    // MARK: - Pop-up sheets

    @ViewBuilder
    private func sheetLayer(top: CGFloat) -> some View {
        if let sheet = activeSheet {
            sheetView(sheet, top: top)
                .transition(.opacity)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func sheetView(_ sheet: S4Sheet, top: CGFloat) -> some View {
        switch sheet {
        case .pickupDates:
            bottomSheetLayer {
                S4CalendarSheet(
                    spec: S4CalendarSpec(
                        title: "Pick-up dates",
                        instructions: "Tap every day you can hand it over.",
                        borrowerDays: [8, 9, 15, 16],
                        borrowerFill: S4.borrowerCell,
                        lenderDays: [21],
                        commonDays: [18, 19],
                        summary: "Sun 18 Oct"
                    ),
                    onNext: { go("701-429") },
                    onClear: {}
                )
            }

        case .returnDates:
            bottomSheetLayer {
                S4CalendarSheet(
                    spec: S4CalendarSpec(
                        title: "Return dates",
                        instructions: "Tap every day you can take it back (after your first pick-up).",
                        borrowerDays: [21],
                        borrowerFill: S4.borrowerCellSel,
                        lenderDays: [19],
                        commonDays: [],
                        summary: "Mon 19 Oct"
                    ),
                    onNext: { go("701-762") },
                    onClear: {}
                )
            }

        case .pickupTimes:
            bottomSheetLayer {
                S4TimesSheet(
                    pickup: true,
                    onBack: back,
                    onDone: {
                        pickupChosen = true
                        withAnimation(.easeOut(duration: 0.25)) { stack = ["701-203"] }
                    }
                )
            }

        case .returnTimes:
            bottomSheetLayer {
                S4TimesSheet(
                    pickup: false,
                    onBack: back,
                    onDone: {
                        returnChosen = true
                        withAnimation(.easeOut(duration: 0.25)) { stack = ["701-203"] }
                    }
                )
            }

        case .map:
            ZStack(alignment: .bottom) {
                scrim(opacity: 0.40, color: S4.ink)
                S4MapSheet {
                    meetingAddress = "Block A Security Desk"
                    withAnimation(.easeOut(duration: 0.25)) { stack = ["701-1059"] }
                }
                .transition(.move(edge: .bottom))
            }

        case .attachment:
            ZStack(alignment: .bottom) {
                scrim(opacity: 0.33, color: S4.ink)
                    .padding(.bottom, 78)
                S4AttachmentSheet { back() }
                    .padding(.bottom, 78)
                    .transition(.move(edge: .bottom))
            }

        case .chooseTimes:
            ZStack(alignment: .top) {
                scrim(opacity: 0.50, color: S4.scrim)
                S4ChooseTimesSheet(
                    pickup: $thomasPickup,
                    returnTime: $thomasReturn
                ) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        stack = ["701-1366", "701-1718"]
                    }
                }
                .padding(.top, top + 187)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func bottomSheetLayer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack(alignment: .bottom) {
            scrim(opacity: 0.50, color: S4.scrim)
            content().transition(.move(edge: .bottom))
        }
    }

    private func scrim(opacity: Double, color: Color) -> some View {
        Rectangle()
            .fill(color)
            .opacity(opacity)
            .contentShape(Rectangle())
            .onTapGesture { back() }
            .transition(.opacity)
    }
}

// MARK: - Shared section-4 components

private struct S4ActionButton: View {
    var title: String
    var enabled: Bool = true
    var fill: Color = S4.brand
    var height: CGFloat = 48
    var font: Font = BFont.bold(16)
    var titleColor: Color? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundStyle(enabled ? Color.white : (titleColor ?? S4.disabledInk))
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(enabled ? fill : S4.disabledFill)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

private struct S4OutlineButton: View {
    var title: String
    var icon: String? = nil
    var height: CGFloat = 44
    var radius: CGFloat = 22
    var fontSize: CGFloat = 14
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(BFont.semibold(fontSize))
            }
            .foregroundStyle(S4.brand)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(S4.surface)
            .clipShape(Capsule(style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(S4.brand, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct S4AvailabilityCard: View {
    var title: String
    var countText: String?
    var date: String
    var times: [String]
    var collapsed: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(S4.brandStroke)
                        .frame(width: 20, height: 20)
                    Text(title)
                        .font(BFont.bold(15))
                        .foregroundStyle(S4.ink)
                    Spacer(minLength: 0)
                    if let countText {
                        Text(countText)
                            .font(BFont.semibold(12))
                            .foregroundStyle(S4.greenText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(S4.pillGrey)
                            .clipShape(Capsule())
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(S4.ink)
                }
                .frame(height: 22)

                if !collapsed {
                    HStack(spacing: 8) {
                        Text(date)
                            .font(BFont.bold(13))
                            .foregroundStyle(S4.ink)
                            .frame(width: 96, alignment: .leading)
                        HStack(spacing: 4) {
                            ForEach(times, id: \.self) { time in
                                Text(time)
                                    .font(BFont.semibold(12))
                                    .foregroundStyle(S4.brandDeep)
                                    .padding(.horizontal, 8)
                                    .frame(height: 24)
                                    .background(S4.brandChip)
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(height: 40)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, collapsed ? 7 : 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(S4.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(S4.stroke, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct S4MatchRow: View {
    var title: String
    var count: String
    var date: String
    var times: [String]
    var summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(S4.brandStroke)
                    .frame(width: 18, height: 18)
                Text(title)
                    .font(BFont.bold(12))
                    .foregroundStyle(S4.inkSecondary)
                Spacer(minLength: 0)
                Text(count)
                    .font(BFont.regular(12))
                    .foregroundStyle(S4.inkSecondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(S4.ink)
            }
            .frame(height: 17)

            HStack(spacing: 8) {
                Text(date)
                    .font(BFont.bold(13))
                    .foregroundStyle(S4.ink)
                    .frame(width: 96, alignment: .leading)
                HStack(spacing: 4) {
                    ForEach(times, id: \.self) { time in
                        Text(time)
                            .font(BFont.semibold(12))
                            .foregroundStyle(S4.brandChipInk)
                            .padding(.horizontal, 8)
                            .frame(height: 24)
                            .background(S4.brandChipAlt)
                            .clipShape(Capsule())
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(height: 24)

            Text(summary)
                .font(BFont.regular(11))
                .foregroundStyle(S4.inkTertiary)
                .frame(height: 14)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(S4.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(S4.strokeField, lineWidth: 1)
        }
    }
}

private struct S4PreferredSpotCard: View {
    private let spots = ["West Wing Lobby", "Block A Security Desk", "Arrange via chat"]
    @State private var selected = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferred meeting spot")
                .font(BFont.bold(15))
                .foregroundStyle(S4.inkDark)
            VStack(spacing: 10) {
                ForEach(Array(spots.enumerated()), id: \.offset) { index, spot in
                    Button {
                        selected = index
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .stroke(S4.brandStroke, lineWidth: 2)
                                    .frame(width: 23, height: 23)
                                if selected == index {
                                    Circle()
                                        .fill(S4.brandStroke)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .frame(width: 24, height: 24)
                            Text(spot)
                                .font(BFont.regular(15))
                                .foregroundStyle(S4.inkDark)
                            Spacer(minLength: 0)
                        }
                        .frame(height: 24)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(S4.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(S4.stroke, lineWidth: 1)
        }
    }
}

private struct S4Banner: View {
    var icon: String
    var tint: Color
    var title: String
    var message: String
    var height: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 16, height: 16)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BFont.bold(15))
                    .foregroundStyle(tint)
                Text(message)
                    .font(BFont.regular(13))
                    .foregroundStyle(S4.greenText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height, alignment: .topLeading)
        .background(S4.greenBanner)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct S4DetailsCard: View {
    var pickup: String
    var returnTime: String
    var meetAt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Garment Steamer")
                .font(BFont.bold(18))
                .foregroundStyle(S4.inkDeep)
            row("Borrower", "James")
            row("Lender", "Thomas")
            row("Pick-up", pickup)
            row("Return", returnTime)
            HStack(alignment: .center, spacing: 12) {
                Text("Meet at")
                    .font(BFont.regular(14))
                    .foregroundStyle(S4.inkMuted)
                    .frame(width: 76, alignment: .leading)
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(S4.inkDeep)
                        .frame(width: 16, height: 16)
                    Text(meetAt)
                        .font(BFont.semibold(14))
                        .foregroundStyle(S4.inkDeep)
                }
                Spacer(minLength: 0)
            }
            .frame(height: 20)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(S4.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(S4.divider, lineWidth: 1)
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(label)
                .font(BFont.regular(14))
                .foregroundStyle(S4.inkMuted)
                .frame(width: 76, alignment: .leading)
            Text(value)
                .font(BFont.semibold(14))
                .foregroundStyle(S4.inkDeep)
            Spacer(minLength: 0)
        }
        .frame(height: 20)
    }
}

private struct S4PersonRow: View {
    var photo: BPhoto?
    var initials: String
    var initialsTint: Color
    var initialsBackground: Color
    var avatarSize: CGFloat
    var name: String
    var rating: String
    var actionTitle: String
    var onSelect: (() -> Void)? = nil
    var action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                onSelect?()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        if let photo {
                            BAvatarView(photo: photo, initials: initials, size: avatarSize)
                        } else {
                            Circle()
                                .fill(initialsBackground)
                                .frame(width: avatarSize, height: avatarSize)
                            Text(initials)
                                .font(BFont.bold(16))
                                .foregroundStyle(initialsTint)
                        }
                    }
                    .frame(width: avatarSize, height: avatarSize)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(BFont.bold(15))
                            .foregroundStyle(S4.inkDeep)
                        Text(rating)
                            .font(BFont.regular(12))
                            .foregroundStyle(S4.inkMuted)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(onSelect == nil)

            Button(action: action) {
                Text(actionTitle)
                    .font(BFont.semibold(13))
                    .foregroundStyle(S4.brand)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 40)
    }
}

private struct S4ChatBubbleRow: View {
    var message: ChatMessage

    var body: some View {
        HStack(spacing: 0) {
            if message.isMine { Spacer(minLength: 0) }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.text)
                    .font(BFont.regular(15))
                    .foregroundStyle(S4.ink)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 3) {
                    Text(message.time)
                        .font(BFont.regular(10))
                        .foregroundStyle(S4.inkSecondary)
                    if message.isMine {
                        Text("✓✓")
                            .font(BFont.regular(10))
                            .foregroundStyle(S4.inkSecondary)
                    }
                }
            }
            .padding(14)
            .frame(width: 290, alignment: .leading)
            .background(message.isMine ? S4.greenSoft : S4.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if !message.isMine { Spacer(minLength: 0) }
        }
    }
}

private struct S4AgreementCard: View {
    var onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "doc.badge.checkmark")
                    .font(.system(size: 23, weight: .regular))
                    .foregroundStyle(S4.brand)
                    .frame(width: 30, height: 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Final Agreement")
                        .font(BFont.bold(16))
                        .foregroundStyle(S4.ink)
                    Text("Garment Steamer · Deposit $10")
                        .font(BFont.regular(12))
                        .foregroundStyle(S4.inkSecondary)
                }
                Spacer(minLength: 0)
            }
            Button(action: onOpen) {
                Text("Open Agreement")
                    .font(BFont.bold(15))
                    .foregroundStyle(S4.brand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay { Capsule().stroke(S4.brand, lineWidth: 1.2) }
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(S4.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(S4.strokeIcon, lineWidth: 0.7)
        }
        .shadow(color: S4.ink.opacity(0.03), radius: 12, x: 0, y: 3)
    }
}

private struct S4Composer: View {
    @Binding var text: String
    var onAttach: () -> Void
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onAttach) {
                Image(systemName: "plus")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(S4.brand)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)

            TextField("", text: $text, prompt: Text("Message Thomas…").foregroundColor(S4.inkSecondary))
                .font(BFont.regular(14))
                .foregroundStyle(S4.ink)

            Button(action: onSend) {
                Image(systemName: "paperplane")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(S4.brand)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 13)
        .frame(height: 48)
        .background(S4.surface)
        .clipShape(Capsule())
        .overlay { Capsule().stroke(S4.strokeIcon, lineWidth: 1) }
    }
}

private struct S4BorroChatButton: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("chat with borro")
                .font(BFont.bold(13))
                .foregroundStyle(.white)
                .padding(.horizontal, 13)
                .frame(height: 34)
                .background(S4.brand)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: S4.ink.opacity(0.08), radius: 12, x: 0, y: 4)

            ZStack {
                Circle().fill(S4.surface)
                BLogoMark(height: 15)
            }
            .frame(width: 56, height: 56)
            .overlay { Circle().stroke(S4.brand, lineWidth: 1.5) }
            .shadow(color: S4.ink.opacity(0.08), radius: 16, x: 0, y: 6)
        }
    }
}

// MARK: - Sheets

private struct S4CalendarSpec {
    var title: String
    var instructions: String
    var borrowerDays: [Int]
    var borrowerFill: Color
    var lenderDays: [Int]
    var commonDays: [Int]
    var summary: String
}

private struct S4CalendarSheet: View {
    var spec: S4CalendarSpec
    var onNext: () -> Void
    var onClear: () -> Void

    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
    private let weeks: [[Int?]] = [
        [nil, nil, nil, 1, 2, 3, 4],
        [5, 6, 7, 8, 9, 10, 11],
        [12, 13, 14, 15, 16, 17, 18],
        [19, 20, 21, 22, 23, 24, 25],
        [26, 27, 28, 29, 30, 31, nil]
    ]
    private let cellWidth: CGFloat = 45.7
    private let leadingInset: CGFloat = 13

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(S4.sheetGrabber)
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 14)

            Text(spec.title)
                .font(BFont.bold(20))
                .foregroundStyle(S4.inkDeep)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Text(spec.instructions)
                .font(BFont.regular(13))
                .foregroundStyle(S4.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 4)

            monthBar
                .padding(.top, 28)

            weekdayRow
                .padding(.top, 13)

            daysGrid
                .padding(.top, 10)

            legend
                .padding(.top, 9)

            Spacer(minLength: 0)

            footer
        }
        .frame(maxWidth: .infinity)
        .frame(height: 640)
        .background(S4.surface)
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous
        ))
    }

    private var monthBar: some View {
        ZStack {
            Text("October 2026")
                .font(BFont.bold(17))
                .foregroundStyle(S4.calInk)
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(S4.calInk)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(S4.calInk)
            }
            .padding(.horizontal, 25)
        }
        .frame(height: 22)
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { _, letter in
                Text(letter)
                    .font(BFont.bold(14))
                    .foregroundStyle(S4.calMuted)
                    .frame(width: cellWidth, height: 22)
            }
        }
        .padding(.leading, leadingInset)
    }

    private var daysGrid: some View {
        VStack(spacing: 0.4) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                        dayCell(day)
                            .frame(width: cellWidth, height: 33)
                    }
                }
            }
        }
        .padding(.leading, leadingInset)
    }

    @ViewBuilder
    private func dayCell(_ day: Int?) -> some View {
        if let day {
            ZStack {
                if spec.borrowerDays.contains(day) {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(spec.borrowerFill)
                        .frame(width: 41, height: 33)
                }
                if spec.lenderDays.contains(day) {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(S4.lenderCell)
                        .frame(width: 41, height: 33)
                }
                if spec.commonDays.contains(day) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(S4.calInk, lineWidth: 1.7)
                        .frame(width: 31, height: 31)
                }
                Text("\(day)")
                    .font(BFont.regular(17))
                    .foregroundStyle(S4.calInk)
            }
        } else {
            Color.clear
        }
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendItem(key: .outline, label: "Common availability")
            legendItem(key: .fill(S4.borrowerKey), label: "Borrower available")
            legendItem(key: .fill(S4.lenderKey), label: "Lender available")
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
    }

    private enum LegendKey {
        case outline
        case fill(Color)
    }

    private func legendItem(key: LegendKey, label: String) -> some View {
        HStack(spacing: 5) {
            switch key {
            case .outline:
                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                    .stroke(S4.calInk, lineWidth: 1.7)
                    .frame(width: 10, height: 10)
            case .fill(let color):
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(color)
                    .frame(width: 10, height: 10)
            }
            Text(label)
                .font(BFont.regular(11))
                .foregroundStyle(S4.calInk)
                .fixedSize()
        }
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(S4.divider)
                .frame(height: 1)

            HStack {
                Text(spec.summary)
                    .font(BFont.semibold(13))
                    .foregroundStyle(S4.inkDeep)
                Spacer()
                Button(action: onClear) {
                    Text("Clear")
                        .font(BFont.semibold(14))
                        .foregroundStyle(S4.brand)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 21)
            .frame(height: 37)

            Button(action: onNext) {
                Text("Next · set times")
                    .font(BFont.bold(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(S4.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
    }
}

private struct S4TimesSheet: View {
    var pickup: Bool
    var onBack: () -> Void
    var onDone: () -> Void

    private var hours: [String] {
        pickup ? ["16", "17", "18", "19", "20"] : ["18", "19", "20", "21", "22"]
    }

    private var tabLabel: String { pickup ? "Sun 18 Oct · 2" : "Mon 19 Oct · 3" }
    private var tabWidth: CGFloat { pickup ? 108 : 124 }
    private var activeDay: String { pickup ? "Sun 18 Oct" : "Mon 19 Oct" }
    private var addLabel: String { pickup ? "Add 8:00 pm" : "Add 11:00 pm" }
    private var chips: [String] {
        pickup ? ["7:00 pm", "7:30 pm"] : ["10:00 pm", "11:00 pm", "11:30 pm"]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(S4.sheetGrabber)
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 14)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 20) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(S4.inkDeep)
                            .frame(width: 6, height: 14)
                    }
                    .buttonStyle(.plain)
                    Text(pickup ? "Pick-up times" : "Return times")
                        .font(BFont.bold(20))
                        .foregroundStyle(S4.inkDeep)
                    Spacer(minLength: 0)
                }
                Text(pickup
                     ? "Pick a day, then add the times you can do."
                     : "After your first pick-up (Sun 18 Oct · 7:30 pm).")
                    .font(BFont.regular(13))
                    .foregroundStyle(S4.inkMuted)
                    .padding(.leading, 26)
            }
            .padding(.leading, 24)
            .padding(.trailing, 20)
            .padding(.top, 8)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Text(tabLabel)
                        .font(BFont.semibold(14))
                        .foregroundStyle(.white)
                        .frame(width: tabWidth, height: 44)
                        .background(S4.brand)
                        .clipShape(Capsule())
                    if pickup {
                        ForEach(0..<3, id: \.self) { _ in
                            Color.clear
                                .frame(width: tabWidth, height: 44)
                                .background(S4.surface)
                                .clipShape(Capsule())
                                .overlay { Capsule().stroke(Color(hex: 0xD5D8DD), lineWidth: 1.5) }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .padding(.top, 12)

            HStack(alignment: .top, spacing: 16) {
                S4TimeWheel(
                    hours: hours,
                    minutes: ["50", "55", "00", "05", "10"],
                    activeHour: 2,
                    activeMinute: 2
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(activeDay)
                        .font(BFont.bold(15))
                        .foregroundStyle(S4.inkDeep)
                        .frame(height: 20)
                    ZStack {
                        Capsule().fill(S4.brand.opacity(0.4))
                        Text(addLabel)
                            .font(BFont.bold(14))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(width: 147, height: 44)
                    Text("Already added.")
                        .font(BFont.regular(12))
                        .foregroundStyle(S4.inkMuted)
                        .frame(height: 16)
                }
                .padding(.top, 36)
            }
            .padding(.leading, 20)
            .padding(.top, 16)

            timesCard
                .padding(.horizontal, 20)
                .padding(.top, 16)

            Spacer(minLength: 0)

            footer
        }
        .frame(maxWidth: .infinity)
        .frame(height: 600)
        .background(S4.surface)
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous
        ))
    }

    private var timesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Times for \(activeDay)")
                    .font(BFont.semibold(13))
                    .foregroundStyle(S4.inkDeep)
                Spacer()
                Text("\(chips.count) times added")
                    .font(BFont.regular(12))
                    .foregroundStyle(S4.inkMuted)
            }
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    HStack(spacing: 5) {
                        Text(chip)
                            .font(BFont.semibold(14))
                            .foregroundStyle(S4.brandDeep)
                        Text("×")
                            .font(BFont.bold(16))
                            .foregroundStyle(S4.brandDeep)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(S4.surface)
                    .clipShape(Capsule())
                    .overlay { Capsule().stroke(S4.brand, lineWidth: 1.5) }
                }
                Spacer(minLength: 0)
            }
            Text("Tap a time to remove it.")
                .font(BFont.regular(12))
                .foregroundStyle(S4.inkMuted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 124, alignment: .topLeading)
        .background(S4.bgAlt)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(S4.divider, lineWidth: 1)
        }
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(S4.divider)
                .frame(height: 1)

            HStack {
                Text("\(chips.count) selected")
                    .font(BFont.semibold(13))
                    .foregroundStyle(S4.inkDeep)
                Spacer()
                Text("Clear times")
                    .font(BFont.semibold(14))
                    .foregroundStyle(S4.brand)
            }
            .padding(.horizontal, 20)
            .padding(.top, 21)
            .frame(height: 37)

            Button(action: onDone) {
                Text("Done")
                    .font(BFont.bold(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(S4.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
    }
}

private struct S4TimeWheel: View {
    var hours: [String]
    var minutes: [String]
    var activeHour: Int
    var activeMinute: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(S4.bgAlt)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(S4.brandChip)
                .frame(width: 174, height: 40)
            HStack(spacing: 0) {
                column(hours, active: activeHour)
                column(minutes, active: activeMinute)
            }
            Text(":")
                .font(BFont.bold(22))
                .foregroundStyle(S4.brandDeep)
        }
        .frame(width: 190, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func column(_ values: [String], active: Int) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                Text(value)
                    .font(index == active ? BFont.bold(24) : BFont.medium(18))
                    .foregroundStyle(index == active ? S4.brandDeep : S4.inkDeep.opacity(0.22))
                    .frame(width: 95, height: 30)
            }
        }
    }
}

private struct S4MapSheet: View {
    var onUse: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a meeting point")
                .font(BFont.bold(21))
                .foregroundStyle(S4.ink)
                .frame(height: 56, alignment: .leading)

            VStack(alignment: .leading, spacing: 7) {
                Text("Search location")
                    .font(BFont.bold(13))
                    .foregroundStyle(S4.ink)
                HStack(spacing: 8) {
                    Image(systemName: "circle")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(S4.ink)
                        .frame(width: 20, height: 20)
                    Text("Bencoolen St")
                        .font(BFont.regular(15))
                        .foregroundStyle(S4.ink)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 13)
                .frame(height: 48)
                .background(S4.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(S4.strokeIcon, lineWidth: 1)
                }
            }

            S4MapArt()
                .frame(height: 270)

            HStack(spacing: 8) {
                mapChip("Your preferred spot", fill: S4.borrowerKey, ink: S4.helperAmber, stroke: nil)
                mapChip("Lender’s spot", fill: S4.lenderKey, ink: S4.helperOrange, stroke: nil)
                mapChip("Shared area", fill: S4.surface, ink: S4.calInk, stroke: S4.calInk)
                Spacer(minLength: 0)
            }
            .frame(height: 23)

            VStack(alignment: .leading, spacing: 5) {
                Text("Suggested midpoint · Block A Security Desk")
                    .font(BFont.bold(14))
                    .foregroundStyle(S4.ink)
                Text("120 m from you · Close to both preferred spots")
                    .font(BFont.regular(13))
                    .foregroundStyle(S4.inkSecondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 66)
            .background(S4.greenSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button(action: onUse) {
                Text("Use this location")
                    .font(BFont.bold(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(S4.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .frame(height: 658)
        .background(S4.surface)
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous
        ))
        .overlay(alignment: .top) {
            Capsule()
                .fill(S4.sheetGrabber)
                .frame(width: 36, height: 4)
                .padding(.top, 8)
        }
    }

    private func mapChip(_ title: String, fill: Color, ink: Color, stroke: Color?) -> some View {
        Text(title)
            .font(BFont.bold(11))
            .foregroundStyle(ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(fill)
            .clipShape(Capsule())
            .overlay {
                if let stroke {
                    Capsule().stroke(stroke, lineWidth: 1.5)
                }
            }
    }
}

private struct S4MapArt: View {
    var body: some View {
        GeometryReader { geo in
            let sx = geo.size.width / 349
            let sy = geo.size.height / 270
            ZStack {
                Canvas { context, size in
                    let ux = size.width / 349
                    let uy = size.height / 270

                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .color(S4.mapBg)
                    )

                    // Streets
                    var vertical = Path()
                    vertical.addRect(CGRect(x: 83 * ux - 20, y: -20,
                                            width: 68.8 * ux, height: size.height + 40))
                    context.fill(vertical, with: .color(.white))

                    var horizontal = Path()
                    horizontal.addRect(CGRect(x: -20, y: 25 * uy,
                                              width: size.width + 40, height: 72.5 * uy))
                    context.fill(horizontal, with: .color(.white))

                    // Blocks
                    context.fill(
                        Path(roundedRect: CGRect(x: 220 * ux, y: 100 * uy,
                                                 width: 90 * ux, height: 60 * uy), cornerRadius: 8),
                        with: .color(S4.mapBlock1)
                    )
                    context.fill(
                        Path(roundedRect: CGRect(x: 15 * ux, y: 15 * uy,
                                                 width: 85 * ux, height: 55 * uy), cornerRadius: 8),
                        with: .color(S4.mapBlock2)
                    )

                    // Coverage circles
                    let c1 = CGPoint(x: 130 * ux, y: 120 * uy)
                    let c2 = CGPoint(x: 225 * ux, y: 155 * uy)
                    let r: CGFloat = 90 * ux

                    let amber = Path(ellipseIn: CGRect(x: c1.x - r, y: c1.y - r,
                                                       width: r * 2, height: r * 2))
                    context.fill(amber, with: .color(S4.mapAmber.opacity(0.92)))
                    context.stroke(amber, with: .color(S4.mapAmberStroke), lineWidth: 1.5)

                    let orange = Path(ellipseIn: CGRect(x: c2.x - r, y: c2.y - r,
                                                        width: r * 2, height: r * 2))
                    context.fill(orange, with: .color(S4.mapOrange.opacity(0.85)))
                    context.stroke(orange, with: .color(S4.mapOrangeStroke), lineWidth: 1.5)

                    // Shared coverage area — the lens where the two circles overlap.
                    let dx = c2.x - c1.x
                    let dy = c2.y - c1.y
                    let d = sqrt(dx * dx + dy * dy)
                    if d > 0 && d < 2 * r {
                        let c1Rect = CGRect(x: c1.x - r, y: c1.y - r, width: r * 2, height: r * 2)
                        let c2Rect = CGRect(x: c2.x - r, y: c2.y - r, width: r * 2, height: r * 2)
                        let circle1 = Path(ellipseIn: c1Rect)
                        let circle2 = Path(ellipseIn: c2Rect)

                        context.drawLayer { layer in
                            layer.clip(to: circle1)
                            layer.fill(circle2, with: .color(.white))
                        }
                        context.drawLayer { layer in
                            layer.clip(to: circle1)
                            layer.stroke(circle2, with: .color(S4.calInk), lineWidth: 1.5)
                        }
                        context.drawLayer { layer in
                            layer.clip(to: circle2)
                            layer.stroke(circle1, with: .color(S4.calInk), lineWidth: 1.5)
                        }
                    }

                    // Current location
                    let dot = CGRect(x: 158 * ux, y: 115 * uy,
                                     width: 16 * ux, height: 16 * uy)
                    context.fill(Path(ellipseIn: dot), with: .color(S4.brand))
                    context.stroke(Path(ellipseIn: dot), with: .color(.white), lineWidth: 3)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text("SINGAPORE · BENCOOLEN")
                    .font(BFont.regular(11))
                    .foregroundStyle(S4.inkSecondary)
                    .position(x: 85 * sx, y: 196 * sy)

                Text("Bras Basah Rd")
                    .font(BFont.regular(10))
                    .foregroundStyle(S4.inkSecondary)
                    .position(x: 219 * sx, y: 76 * sy)

                mapPin("Blk 12", tint: S4.pinAmber)
                    .position(x: 93 * sx, y: 67 * sy)

                mapPin("Blk 48", tint: S4.pinOrange)
                    .position(x: 235 * sx, y: 160 * sy)
            }
        }
    }

    private func mapPin(_ label: String, tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin.circle")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(tint)
            Text(label)
                .font(BFont.bold(12))
                .foregroundStyle(.black)
        }
        .padding(7)
        .background(S4.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct S4AttachmentSheet: View {
    var onPick: () -> Void

    private let options: [(icon: String, label: String)] = [
        ("photo", "Photo"),
        ("video", "Video"),
        ("camera", "Camera"),
        ("mappin", "Location")
    ]

    var body: some View {
        BSheetSurface {
            VStack(alignment: .leading, spacing: 14) {
                Text("Add an attachment")
                    .font(BFont.bold(20))
                    .foregroundStyle(S4.ink)

                HStack(spacing: 8) {
                    ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                        Button(action: onPick) {
                            VStack(spacing: 8) {
                                Image(systemName: option.icon)
                                    .font(.system(size: 22, weight: .regular))
                                    .foregroundStyle(S4.brand)
                                    .frame(width: 48, height: 48)
                                    .background(S4.greenSoft)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                Text(option.label)
                                    .font(BFont.regular(12))
                                    .foregroundStyle(.black)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 71)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 148, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct S4ChooseTimesSheet: View {
    @Binding var pickup: String?
    @Binding var returnTime: String?
    var onConfirm: () -> Void

    private let pickupOptions = ["7 pm", "7:30 pm"]
    private let returnOptions = ["10 pm", "11 pm", "11:30 pm"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Choose your times")
                    .font(BFont.bold(20))
                    .foregroundStyle(S4.inkDeep)
                Text("Tap one pick-up time and one return time.")
                    .font(BFont.regular(13))
                    .foregroundStyle(S4.inkMuted)
            }

            group(title: "Pick-up", date: "Sun 18 Oct", options: pickupOptions) { option in
                pickup = option
            }
            group(title: "Return", date: "Mon 19 Oct", options: returnOptions) { option in
                returnTime = option
            }

            Button(action: onConfirm) {
                Text("Choose pick-up and return")
                    .font(BFont.semibold(15))
                    .foregroundStyle(bothChosen ? .white : S4.disabledInk2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(bothChosen ? S4.brand : Color(hex: 0xD5D8DD))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!bothChosen)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .background(S4.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(alignment: .top) {
            Capsule()
                .fill(S4.sheetGrabber)
                .frame(width: 36, height: 4)
                .padding(.top, 16)
        }
    }

    private var bothChosen: Bool { pickup != nil && returnTime != nil }

    private func group(
        title: String,
        date: String,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                    .font(BFont.bold(16))
                    .foregroundStyle(S4.inkDeep)
                Spacer()
                Text("Choose one")
                    .font(BFont.semibold(12))
                    .foregroundStyle(S4.inkMuted)
            }
            .padding(.horizontal, 14)
            .frame(height: 28)

            HStack(spacing: 10) {
                Text(date)
                    .font(BFont.bold(14))
                    .foregroundStyle(S4.inkDeep)
                    .frame(width: 84, alignment: .leading)
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            onSelect(option)
                        } label: {
                            Text(option)
                                .font(BFont.semibold(15))
                                .foregroundStyle(selection(for: title) == option ? .white : S4.brandDeep)
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(selection(for: title) == option ? S4.brand : S4.surface)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().stroke(
                                        selection(for: title) == option ? S4.brand : Color(hex: 0xD5D8DD),
                                        lineWidth: 1.5
                                    )
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(height: 65)
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 115, alignment: .topLeading)
        .background(S4.bgAlt)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(S4.divider, lineWidth: 1)
        }
    }

    private func selection(for title: String) -> String? {
        title == "Pick-up" ? pickup : returnTime
    }
}
