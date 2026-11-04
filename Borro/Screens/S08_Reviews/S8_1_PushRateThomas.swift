import SwiftUI

/// Figma frame "8.1 James · Push · rate Thomas" (node 703:3018).
struct S8_1_PushRateThomasView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        PushNotificationScreen(
            date: appState.returnDay.lockScreen, time: Scenario.reviewPushTime,
            title: "How was Thomas's steamer?",
            message: "Return confirmed. Tap to rate your borrowing and help neighbours borrow with confidence.",
            meta: "Thomas · Garment Steamer · \(appState.borrowRangeShort)"
        ) { router.go(.s8_2) }
    }
}

#Preview {
    PreviewHost(.s8_1)
}
