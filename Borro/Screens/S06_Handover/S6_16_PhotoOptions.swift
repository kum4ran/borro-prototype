import SwiftUI

/// Figma frame "6.16 James · Photo options" (node 703:2512).
struct S6_16_PhotoOptionsView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        OverlayContainer(alignment: .top, dimmed: false) {
            PhotoOptionsMenu {
                appState.removePhoto(.extra, from: .collection)
                router.go(.s6_14)
            } onUpload: {
                router.go(.s6_15)
            } onRetake: {
                router.go(.s6_15)
            }
            .padding(.top, Size.photoMenuTop)
        }
    }
}

#Preview {
    PreviewHost(.s6_16)
}
