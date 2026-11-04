import SwiftUI

/// Renders one frame inside the real shell with fresh fixture state, for #Preview.
struct PreviewHost: View {
    @State private var appState = AppState()
    @State private var router = Router()
    private let screen: Screen
    private let prepare: (AppState) -> Void

    init(_ screen: Screen, prepare: @escaping (AppState) -> Void = { _ in }) {
        self.screen = screen
        self.prepare = prepare
    }

    var body: some View {
        RootView()
            .environment(appState)
            .environment(router)
            .onAppear {
                Inter.registerAll()
                router.appState = appState
                prepare(appState)
                router.jump(to: screen)
                appState.clearRoleBanner()
            }
    }
}
