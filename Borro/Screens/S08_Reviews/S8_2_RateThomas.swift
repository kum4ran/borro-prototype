import SwiftUI

/// Figma frame "8.2 James · Rate Thomas" (node 691:6828). Any star fills the form (Figma "Five star controls" → 8.3).
struct S8_2_RateThomasView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        RatePage(person: MockData.thomas, comment: nil, stars: appState.thomasCategoryStars,
                 complete: false, onStar: { stars, _ in
                     // Figma: the first tap fills the form (8.3); every category takes the stars tapped.
                     appState.rateThomas(stars)
                     router.go(.s8_3)
                 }, onSubmit: {})
    }
}

#Preview {
    PreviewHost(.s8_2)
}
