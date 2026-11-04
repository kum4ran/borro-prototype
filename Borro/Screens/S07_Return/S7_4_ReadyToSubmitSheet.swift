import SwiftUI

/// Figma frame "7.4 Thomas · Ready to submit? (sheet)" (node 703:2867).
struct S7_4_ReadyToSubmitSheetView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ReadyToSubmitSheet(codeWord: "return", review: .s7_3) {
            appState.setStatus(.returned)
            router.go(.s7_5)
        }
    }
}

#Preview {
    PreviewHost(.s7_4)
}
