import SwiftUI

/// Figma frame "3.8 James · Push · request accepted" (node 700:520).
struct S3_8_PushRequestAcceptedView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    private let thomas = MockData.thomas

    var body: some View {
        PushNotificationScreen(
            date: Scenario.requestDay.lockScreen,
            title: "Thomas accepted your request",
            message: "Garment Steamer · \(appState.borrowRangeShort). Tap to arrange pick-up and meeting spot.",
            meta: "Thomas · ★ \(thomas.rating) (\(thomas.reviewCount) reviews)"
        ) { router.go(.s3_9) }
    }
}

#Preview {
    PreviewHost(.s3_8)
}
