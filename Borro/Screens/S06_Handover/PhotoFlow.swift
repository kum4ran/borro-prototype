import SwiftUI

/// Photo rules. CONFLICT: the brief says only the front photo is required; Figma copy and links
/// (6.14a → Missing photos, "Front and back are required") also require the back. Flip here.
enum PhotoRules {
    static let backRequired = false

    static func isComplete(_ set: PhotoSet) -> Bool {
        set.hasFront && (!backRequired || set.hasBack)
    }

    static var requirementLine: String {
        backRequired ? "Clear photos protect both of you. Front and back are required."
                     : "Clear photos protect both of you. The front photo is required."
    }
}

/// One of the three photo flows and the Figma frame for each step.
enum PhotoFlow {
    case dropOff      // Thomas, 6.1–6.9
    case collection   // James, 6.14–6.18
    case returned     // Thomas, 7.2–7.4

    var set: PhotoSetID {
        switch self {
        case .dropOff: return .dropOff
        case .collection: return .collection
        case .returned: return .returned
        }
    }

    /// Frame showing `slot`, with or without its photo.
    func screen(for slot: PhotoSlot, filled: Bool) -> Screen {
        switch (self, slot, filled) {
        case (.dropOff, .front, false): return .s6_1
        case (.dropOff, .front, true): return .s6_4
        case (.dropOff, .back, false): return .s6_5
        case (.dropOff, .back, true): return .s6_5a
        case (.dropOff, .extra, false): return .s6_6
        case (.dropOff, .extra, true): return .s6_6a
        case (.collection, .front, false): return .s6_14
        case (.collection, .front, true): return .s6_14a
        case (.collection, .back, false): return .s6_14b
        case (.collection, .back, true): return .s6_14c
        case (.collection, .extra, false): return .s6_14d
        case (.collection, .extra, true): return .s6_15
        case (.returned, .front, false): return .s7_2
        case (.returned, .front, true): return .s7_2a
        case (.returned, .back, false): return .s7_2b
        case (.returned, .back, true): return .s7_2c
        case (.returned, .extra, false): return .s7_2d
        case (.returned, .extra, true): return .s7_3
        }
    }

    /// Thomas names each drop-off photo first (6.3, 6.3a, 6.3b). The other flows add straight away.
    func nameSheet(for slot: PhotoSlot) -> Screen? {
        guard self == .dropOff else { return nil }
        switch slot {
        case .front: return .s6_3
        case .back: return .s6_3a
        case .extra: return .s6_3b
        }
    }

    var optionsMenu: Screen? {
        switch self {
        case .dropOff: return .s6_7
        case .collection: return .s6_16
        case .returned: return nil
        }
    }

    var readySheet: Screen {
        switch self {
        case .dropOff: return .s6_9
        case .collection: return .s6_18
        case .returned: return .s7_4
        }
    }

    var title: String {
        switch self {
        case .dropOff: return "Drop-off"
        case .collection: return "Collection"
        case .returned: return "Return · Lender"
        }
    }

    var heading: String { self == .dropOff ? "Photograph it as you leave it." : "Photograph it as you collect it." }

    var confirmTitle: String {
        switch self {
        case .dropOff: return "Confirm Drop-off"
        case .collection: return "Confirm Collection"
        case .returned: return "Confirm Return"
        }
    }

    func photo(for slot: PhotoSlot) -> Photo { slot == .extra ? .steamerMain : .steamerShirt }

    func caption(for slot: PhotoSlot, filled: Bool) -> String {
        switch slot {
        case .front: return "FRONT · Required"
        case .back: return PhotoRules.backRequired ? "BACK · Required" : "BACK · Optional"
        case .extra: return filled ? "Left · Steamer" : "POSITION · Edit"
        }
    }
}

/// Shared body of every photo-step frame.
struct PhotoStepPage<Top: View>: View {
    let flow: PhotoFlow
    let slot: PhotoSlot
    var codeLocked = false
    @ViewBuilder var top: () -> Top

    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        let set = appState.photoSet(flow.set)
        let filled = set.has(slot) && !codeLocked
        ScreenScaffold {
            BackAppBar(title: flow.title, subtitle: Scenario.meetUpPlace)
        } content: {
            Text("Garment Steamer").font(.b(.s14)).foregroundStyle(Color.ink)
            top()
            VStack(alignment: .leading, spacing: Space.x4) {
                Text(flow.heading).font(.b(.s16)).foregroundStyle(Color.ink)
                if flow != .dropOff {
                    Text(PhotoRules.requirementLine).font(.r(.s10)).foregroundStyle(Color.inkSecondary)
                }
            }
            VStack(spacing: Space.x10) {
                PhotoSlotView(photo: filled ? flow.photo(for: slot) : nil,
                              emptyLabel: slot == .extra ? "Add Additional Photos" : "Add photo",
                              onAdd: add,
                              onMore: flow.optionsMenu.map { menu in { router.go(menu) } })
                Button {
                    if flow == .dropOff, slot == .front, filled { router.go(.s6_8) }
                } label: {
                    HStack(spacing: Space.x4) {
                        Text(flow.caption(for: slot, filled: filled)).font(.b(.s10)).foregroundStyle(Color.ink)
                        if filled || slot == .extra { IconView(icon: .pencil, size: Size.iconTiny).foregroundStyle(Color.ink) }
                    }
                    .frame(minHeight: Size.hitTarget)
                }
                .buttonStyle(.plain)
                .padding(.vertical, -Space.x10)
                .accessibilityIdentifier("photoCaption")
                PhotoPager(current: PhotoSlot.allCases.firstIndex(of: slot) ?? 0,
                           filled: PhotoSlot.allCases.map { set.has($0) && !codeLocked }) { index in
                    let target = PhotoSlot.allCases[index]
                    router.go(flow.screen(for: target, filled: set.has(target)))
                }
            }
            if flow == .dropOff {
                Text(PhotoRules.requirementLine).font(.r(.s10)).foregroundStyle(Color.inkSecondary)
            }
        } actions: {
            confirmButton(complete: PhotoRules.isComplete(set) && !codeLocked)
        }
    }

    @ViewBuilder
    private func confirmButton(complete: Bool) -> some View {
        if complete {
            PrimaryButton(title: flow.confirmTitle, identifier: "confirmPhotosButton") { router.go(flow.readySheet) }
        } else if flow == .collection && !codeLocked {
            // Figma wires the greyed button to the Missing photos sheet (6.17).
            MutedButton(title: flow.confirmTitle) { router.go(.s6_17) }
                .accessibilityIdentifier("confirmPhotosButton")
        } else {
            PrimaryButton(title: flow.confirmTitle, enabled: false, identifier: "confirmPhotosButton") {}
        }
    }

    private func add() {
        if codeLocked { return }
        if let sheet = flow.nameSheet(for: slot) {
            router.go(sheet)
        } else {
            appState.addPhoto(slot, to: flow.set)
            router.go(flow.screen(for: slot, filled: true))
        }
    }
}

/// Name sheet for a drop-off photo (6.3, 6.3a, 6.3b, and 6.8 for edits).
struct PhotoNameSheet: View {
    let slot: PhotoSlot
    var editing = false

    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        SheetContainer(title: editing ? "Edit Name" : "Name of picture") {
            VStack(spacing: Space.x16) {
                Text(editing ? "Right Side - steamer" : "Example: Left Side  - speaker")
                    .font(.r(.s14))
                    .foregroundStyle(editing ? Color.ink : Color.inkSecondary)
                    .frame(maxWidth: .infinity, minHeight: Size.nameField, alignment: .topLeading)
                    .padding(Space.x12)
                    .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.card))
                    .overlay(RoundedRectangle(cornerRadius: Radius.card).strokeBorder(Color.stroke, lineWidth: Size.stroke))
                SecondaryButton(title: editing ? "Cancel edit" : "Cancel Upload") {
                    router.go(editing ? .s6_4 : PhotoFlow.dropOff.screen(for: slot, filled: false))
                }
                PrimaryButton(title: editing ? "Confirm edit" : "Confirm upload", identifier: "confirmUploadButton") {
                    if !editing { appState.addPhoto(slot, to: .dropOff) }
                    router.go(PhotoFlow.dropOff.screen(for: slot, filled: true))
                }
            }
        }
    }
}

/// "Ready to submit?" sheet (6.9, 6.18, 7.4).
struct ReadyToSubmitSheet: View {
    let codeWord: String
    let review: Screen
    let confirm: () -> Void

    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(title: "Ready to submit?") {
            VStack(alignment: .leading, spacing: Space.x14) {
                ResultSealIcon(icon: .shieldCheck)
                Text("Your \(codeWord) code and required front\(PhotoRules.backRequired ? "/back" : "") photos are ready.")
                    .font(.r(.s14)).foregroundStyle(Color.ink)
                Text("These condition records protect both members. Check that the photos are clear.")
                    .font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                SecondaryButton(title: "Go back and review") { router.go(review) }
                PrimaryButton(title: "Confirm submission", identifier: "confirmSubmissionButton", action: confirm)
            }
        }
    }
}

/// Shield or check glyph at the top of the info sheets.
struct ResultSealIcon: View {
    let icon: Icon
    var body: some View {
        IconView(icon: icon, size: Size.sheetIcon).foregroundStyle(Color.brand)
    }
}

/// Info sheet with an icon, title, text and "Got it" (6.2, 6.13, 6.17).
struct InfoSheet: View {
    let title: String
    var subtitle: String?
    let message: String
    var warning: String?
    var alert: String?
    let done: Screen

    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer {
            VStack(alignment: .leading, spacing: Space.x10) {
                ResultSealIcon(icon: .shieldCheck)
                Text(title).font(.b(.s20)).foregroundStyle(Color.ink)
                if let subtitle { Text(subtitle).font(.b(.s11)).foregroundStyle(Color.brand) }
                if let alert { Text(alert).font(.r(.s13)).foregroundStyle(Color.danger) }
                Text(message).font(.r(.s14)).foregroundStyle(Color.ink)
                if let warning { Text(warning).font(.r(.s13)).foregroundStyle(Color.danger) }
                PrimaryButton(title: "Got it", identifier: "gotItButton") { router.go(done) }
                    .padding(.top, Space.x6)
            }
        }
    }
}
