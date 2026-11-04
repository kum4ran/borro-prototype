import SwiftUI

/// Figma frame "8.3 James · Rate Thomas · filled" (node 703:3041).
struct S8_3_RateThomasFilledView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        RatePage(person: MockData.thomas, comment: MockData.reviewOfThomas, stars: appState.thomasCategoryStars,
                 complete: appState.thomasReviewComplete,
                 onStar: { appState.rateThomas($0, category: $1) },
                 onSubmit: { router.go(.s8_4) })
    }
}

#Preview {
    PreviewHost(.s8_3)
}
