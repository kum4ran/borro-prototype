import SwiftUI

@main
struct BorroApp: App {
    @StateObject private var store = BorroStore()

    init() {
        BFonts.registerIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            AppShell()
                .environmentObject(store)
                .preferredColorScheme(.light)
                .tint(BColor.brand)
        }
    }
}
