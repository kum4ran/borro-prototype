import SwiftUI

/// Figma frame "6.18 James · Ready to submit? (sheet)" (node 703:2615).
struct S6_18_ReadyToSubmitSheetView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ReadyToSubmitSheet(codeWord: "collection", review: .s6_15) {
            appState.setStatus(.onLoan)
            router.go(.s6_19)
        }
    }
}

#Preview {
    PreviewHost(.s6_18)
}
