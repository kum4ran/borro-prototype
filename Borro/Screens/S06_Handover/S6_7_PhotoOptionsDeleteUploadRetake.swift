import SwiftUI

/// Figma frame "6.7 Thomas · Photo options (delete / upload / retake)" (node 703:1074).
struct S6_7_PhotoOptionsDeleteUploadRetakeView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        OverlayContainer(alignment: .top, dimmed: false) {
            PhotoOptionsMenu {
                appState.removePhoto(.front, from: .dropOff)
                router.go(.s6_1)
            } onUpload: {
                router.go(.s6_3)
            } onRetake: {
                router.go(.s6_3)
            }
            .padding(.top, Size.photoMenuTop)
        }
    }
}

#Preview {
    PreviewHost(.s6_7)
}
