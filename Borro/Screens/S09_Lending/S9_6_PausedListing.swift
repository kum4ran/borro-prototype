import SwiftUI

/// Figma frame "9.6 Thomas · Paused listing" (node 708:775).
struct S9_6_PausedListingView: View {
    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(title: "Manage paused listing", showsHandle: false) {
            VStack(spacing: Space.x12) {
                Text("Water Bottle is hidden from discovery. Any loan already in progress continues as normal, and you can still respond to existing requests.")
                    .font(.r(.s13)).foregroundStyle(Color.inkSecondary).multilineTextAlignment(.center)
                PrimaryButton(title: "Resume listing") { router.go(.s9_1) }
                SecondaryButton(title: "Archive listing") { router.go(.s9_1) }
            }
        }
        .padding(.top, Space.x16)
    }
}

#Preview {
    PreviewHost(.s9_6)
}
