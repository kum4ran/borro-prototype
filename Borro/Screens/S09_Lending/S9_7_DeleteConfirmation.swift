import SwiftUI

/// Figma frame "9.7 Thomas · Delete confirmation" (node 708:889).
struct S9_7_DeleteConfirmationView: View {
    @Environment(Router.self) private var router

    var body: some View {
        OverlayContainer {
            VStack(alignment: .leading, spacing: Space.x16) {
                Text("Delete this listing?").font(.b(.s21)).foregroundStyle(Color.ink)
                Text("This can’t be undone.").font(.r(.s14)).foregroundStyle(Color.inkSecondary)
                PrimaryButton(title: "Delete", fill: .danger) { router.go(.s9_1) }
                SecondaryButton(title: "Cancel") { router.go(.s9_1) }
            }
            .padding(Space.x20)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.r16))
            .padding(.horizontal, Space.x40)
        }
    }
}

#Preview {
    PreviewHost(.s9_7)
}
