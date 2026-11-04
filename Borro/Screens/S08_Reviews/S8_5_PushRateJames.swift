import SwiftUI

/// Figma frame "8.5 Thomas · Push · rate James" (node 703:3129).
struct S8_5_PushRateJamesView: View {
    @Environment(Router.self) private var router

    var body: some View {
        PushNotificationScreen(
            date: Scenario.reviewPushDate, time: Scenario.reviewPushTime,
            title: "How was James with your steamer?",
            message: "Return confirmed. Tap to rate James. Your review updates his credibility score.",
            meta: "James · Garment Steamer · 18–19 Oct"
        ) { router.go(.s8_6) }
    }
}

#Preview {
    PreviewHost(.s8_5)
}
