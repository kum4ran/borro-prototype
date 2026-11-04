import SwiftUI

/// Figma frame "6.9 Thomas · Ready to submit? (sheet)" (node 703:1718).
struct S6_9_ReadyToSubmitSheetView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ReadyToSubmitSheet(codeWord: "drop-off", review: .s6_6) {
            appState.saveDropOff()
            router.go(.s6_10)
        }
    }
}

#Preview {
    PreviewHost(.s6_9)
}
