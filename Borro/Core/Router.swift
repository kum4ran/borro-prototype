import SwiftUI
import Observation

enum AppTab: String, CaseIterable, Hashable {
    case home, borro, lend, you

    var title: String { rawValue.capitalized }

    /// Tab roots from the Figma bottom navigation links.
    var root: Screen {
        switch self {
        case .home: return .s1_1
        case .borro: return .s2_4
        case .lend: return .s9_1
        case .you: return .s8_9
        }
    }
}

enum Presentation: Hashable {
    case page                    // pushed on the navigation stack
    case push                    // lock-screen notification mock, pushed full screen
    case sheet(height: CGFloat)  // bottom sheet over the current page
    case overlay                 // menu or dialog drawn over the current page
}

/// Owns the navigation stack, the sheet and the overlay. Views never push destinations inline.
/// Figma links name a frame, not a direction, so `go(_:)` turns a link into the right move:
/// a sheet or overlay is presented, a frame already in the stack is popped back to, anything else is pushed.
@Observable
@MainActor
final class Router {
    var root: Screen = .s1_1
    var path: [Screen] = []
    private(set) var sheet: Screen?
    private(set) var overlay: Screen?

    weak var appState: AppState?

    /// The page under any sheet or overlay.
    var currentPage: Screen { path.last ?? root }
    /// What the user is looking at.
    var visible: Screen { overlay ?? sheet ?? currentPage }

    func go(_ screen: Screen) {
        appState?.switchRole(to: screen.role)
        switch screen.presentation {
        case .sheet:
            overlay = nil
            sheet = screen
        case .overlay:
            sheet = nil
            overlay = screen
        case .page, .push:
            sheet = nil
            overlay = nil
            if screen == root {
                path.removeAll()
            } else if let index = path.lastIndex(of: screen) {
                path.removeSubrange((index + 1)...)
            } else {
                path.append(screen)
            }
        }
    }

    /// Back chevron with no explicit Figma target, and Figma's BACK action.
    func back() {
        if overlay != nil { overlay = nil; return }
        if sheet != nil { sheet = nil; return }
        if !path.isEmpty { path.removeLast() }
        appState?.switchRole(to: currentPage.role)
    }

    func dismissSheet() {
        sheet = nil
        appState?.switchRole(to: currentPage.role)
    }

    func dismissOverlay() {
        overlay = nil
    }

    /// Bottom tab bar: jumps to the tab's root frame.
    func select(_ tab: AppTab) {
        sheet = nil
        overlay = nil
        root = tab.root
        path.removeAll()
        appState?.switchRole(to: root.role)
    }

    /// Demo menu: open any frame directly. Builds a sensible page underneath sheets and overlays.
    func jump(to screen: Screen) {
        appState?.prepareForDemo(screen)
        sheet = nil
        overlay = nil
        path.removeAll()
        switch screen.presentation {
        case .page, .push:
            root = screen
        case .sheet, .overlay:
            root = Self.pageUnder[screen] ?? .s1_1
            go(screen)
        }
        appState?.switchRole(to: screen.role)
    }

    func reset() {
        sheet = nil
        overlay = nil
        path.removeAll()
        root = .s1_1
    }

    /// The page each sheet or overlay sits on in Figma.
    static let pageUnder: [Screen: Screen] = [
        .s1_3: .s1_2, .s1_4: .s1_2, .s2_2: .s2_1, .s3_7: .s3_3,
        .s4_2: .s4_1, .s4_3: .s4_1, .s4_4: .s4_1, .s4_5: .s4_1, .s4_6: .s4_1,
        .s4_10: .s4_9, .s4_12: .s4_11,
        .s5_2a: .s5_2, .s5_3: .s5_2, .s5_4: .s5_2,
        .s6_2: .s6_1, .s6_3: .s6_1, .s6_3a: .s6_5, .s6_3b: .s6_6, .s6_7: .s6_4, .s6_8: .s6_4,
        .s6_9: .s6_6, .s6_13: .s6_11, .s6_16: .s6_15, .s6_17: .s6_14, .s6_18: .s6_15,
        .s7_4: .s7_3, .s9_2: .s9_1, .s9_4: .s9_3, .s9_5: .s9_1, .s9_6: .s9_1, .s9_7: .s9_1,
        .s11_1: .s2_1, .s11_2: .s2_1,
    ]
}
