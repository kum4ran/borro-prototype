import SwiftUI

/// Figma frame "3.1 Thomas · Push · new request" (node 691:5139).
struct S3_1_PushNewRequestView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    private let james = MockData.james

    var body: some View {
        PushNotificationScreen(
            date: Scenario.requestDay.lockScreen,
            title: "James wants to borrow your Garment Steamer",
            message: "Borrow Now (urgent) · \(appState.borrowRangeShort). Tap to review his profile and respond.",
            meta: "James · \(james.credibility)/100 credibility · ★ \(james.rating) (\(james.reviewCount) reviews)"
        ) { router.go(.s3_2) }
    }
}

#Preview {
    PreviewHost(.s3_1)
}
