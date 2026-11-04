import SwiftUI

/// Navigation stack, sheet, overlay, role banner and the hidden demo menu.
struct RootView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @State private var showsDemoMenu = false

    var body: some View {
        @Bindable var router = router
        ZStack(alignment: .top) {
            NavigationStack(path: $router.path) {
                ScreenHost(screen: router.root)
                    .id(router.root)
                    .navigationDestination(for: Screen.self) { ScreenHost(screen: $0) }
            }
            .sheet(isPresented: sheetBinding) {
                if let sheet = router.sheet {
                    ScreenHost(screen: sheet)
                        .presentationDetents([sheet.detent])
                        .presentationDragIndicator(.hidden)
                        .presentationCornerRadius(Radius.sheet)
                        .presentationBackground(Color.surface)
                }
            }

            if let overlay = router.overlay {
                ScreenHost(screen: overlay)
                    .transition(.opacity)
            }

            if let banner = appState.roleBanner {
                RoleBanner(text: banner)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: banner) {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { appState.clearRoleBanner() }
                    }
            }

            StatusBarHotspot { showsDemoMenu = true }
        }
        .animation(.easeOut(duration: 0.2), value: router.overlay)
        .animation(.easeOut(duration: 0.25), value: appState.roleBanner)
        .sheet(isPresented: $showsDemoMenu) {
            DemoMenu()
        }
        // The brief asks for Dynamic Type up to xxxLarge; accessibility sizes above that are capped.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private var sheetBinding: Binding<Bool> {
        Binding(get: { router.sheet != nil },
                set: { if !$0 { router.dismissSheet() } })
    }
}

/// Wraps a frame's view with the tab bar Figma shows on it.
struct ScreenHost: View {
    let screen: Screen

    var body: some View {
        screen.view
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let tab = screen.tab { AppTabBar(active: tab) }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden()
            .background(screen.background.ignoresSafeArea())
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("screen.\(screen.code)")
    }
}

extension Screen {
    var background: Color {
        switch presentation {
        case .overlay: return .clear
        case .sheet: return .surface
        case .page, .push: return .canvas
        }
    }

    var detent: PresentationDetent {
        if case .sheet(let height) = presentation { return .height(height) }
        return .large
    }
}

/// "Now viewing as Thomas": makes a role switch read like handing over the phone.
struct RoleBanner: View {
    let text: String

    var body: some View {
        HStack(spacing: Space.x8) {
            IconView(icon: .userRound, size: Size.iconSmall)
            Text(text).font(.b(.s14))
        }
        .foregroundStyle(Color.surface)
        .padding(.horizontal, Space.x16)
        .padding(.vertical, Space.x10)
        .background(Color.ink, in: Capsule())
        .raisedShadow()
        .padding(.top, Space.x8)
        .accessibilityIdentifier("roleBanner")
        .allowsHitTesting(false)
    }
}

/// Invisible strip over the status bar. Long-press opens the demo menu.
struct StatusBarHotspot: View {
    let action: () -> Void

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .frame(height: max(proxy.safeAreaInsets.top, Size.hitTarget))
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: 0.6, perform: action)
                .offset(y: -proxy.safeAreaInsets.top)
                .accessibilityLabel("Demo menu")
                .accessibilityAddTraits(.isButton)
                .accessibilityAction(named: "Open demo menu", action)
                .accessibilityIdentifier("demoMenuHotspot")
        }
        .frame(height: 0)
    }
}
