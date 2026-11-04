import SwiftUI

@main
struct BorroApp: App {
    @State private var appState: AppState
    @State private var router: Router

    init() {
        Inter.registerAll()
        let state = AppState()
        let router = Router()
        router.appState = state
        if let start = LaunchArguments.startScreen {
            router.jump(to: start)
        }
        _appState = State(initialValue: state)
        _router = State(initialValue: router)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(router)
                .preferredColorScheme(.light)
                .tint(.brand)
                .task { await appState.runCodeTimer() }
        }
    }
}

/// `-startScreen 5.2` opens a frame directly (used by the screenshot script and UI tests).
enum LaunchArguments {
    static var startScreen: Screen? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-startScreen"), i + 1 < args.count else { return nil }
        return Screen.allCases.first { $0.code == args[i + 1] }
    }
}
