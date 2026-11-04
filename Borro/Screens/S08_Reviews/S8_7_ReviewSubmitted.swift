import SwiftUI

/// Figma frame "8.7 Thomas · Review submitted" (node 703:3152).
struct S8_7_ReviewSubmittedView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ReviewSubmittedPage(person: "James", stars: appState.jamesCategoryStars,
                            action: "Back to My Lending", actionID: "backToMyLendingButton") {
            router.go(.s9_1)
        } extra: {
            EmptyView()
        }
    }
}

#Preview {
    PreviewHost(.s8_7)
}
