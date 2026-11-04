import SwiftUI

/// Figma frame "8.6 Thomas · Rate James" (node 691:6963). Figma shows it already filled.
struct S8_6_RateJamesView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        RatePage(person: MockData.james, comment: MockData.reviewOfJames, stars: appState.jamesCategoryStars,
                 complete: appState.jamesReviewComplete,
                 onStar: { appState.rateJames($0, category: $1) },
                 onSubmit: {
                     appState.submitThomasReview()
                     router.go(.s8_7)
                 })
        .onAppear { if !appState.jamesReviewComplete { appState.rateJames(Review.maxStars) } }
    }
}

#Preview {
    PreviewHost(.s8_6)
}
