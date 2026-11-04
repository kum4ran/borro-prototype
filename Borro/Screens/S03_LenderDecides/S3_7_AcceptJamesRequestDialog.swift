import SwiftUI

/// Figma frame "3.7 Thomas · Accept James' request? (dialog)" (node 700:439). Dialog over 3.3.
struct S3_7_AcceptJamesRequestDialogView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        OverlayContainer {
            VStack(alignment: .leading, spacing: Space.x18) {
                Text("Accept James’ request?").font(.b(.s23)).foregroundStyle(Color.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("Accept James’ request for \(appState.borrowRangeShort)? You’ll arrange the pickup together after confirming.")
                    .font(.b(.s16)).foregroundStyle(Color.inkSecondary)
                VStack(spacing: Space.x18) {
                    PrimaryButton(title: "Confirm", identifier: "confirmAcceptButton") {
                        appState.setStatus(.handoverPending)
                        router.go(.s3_8)
                    }
                    SecondaryButton(title: "Cancel") { router.go(.s3_3) }
                }
            }
            .padding(Space.x24)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.r20))
            .padding(.horizontal, Space.x16)
        }
    }
}

#Preview {
    PreviewHost(.s3_7)
}
