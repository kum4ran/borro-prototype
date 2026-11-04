import SwiftUI

/// Figma frame "9.5 Thomas · Manage listing menu" (node 708:648).
struct S9_5_ManageListingMenuView: View {
    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(title: "Manage Speaker") {
            VStack(alignment: .leading, spacing: 0) {
                row(.pencil, "Edit Listing") { router.go(.s9_9) }
                row(.pause, "Pause Listing") { router.go(.s9_6) }
                row(.star, "Mark as Important") {}
                row(.trash2, "Delete", muted: true) { router.go(.s9_7) }
                Text("You can delete this item after it’s returned.").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    .padding(.top, Space.x8)
            }
        }
    }

    private func row(_ icon: Icon, _ title: String, muted: Bool = false, action: @escaping () -> Void) -> some View {
        TapArea(accessibilityLabel: title, action: action) {
            HStack(spacing: Space.x14) {
                IconView(icon: icon, size: Size.iconSmall)
                Text(title).font(.m(.s16))
                Spacer()
            }
            .foregroundStyle(muted ? Color.greySilver : Color.ink)
            .frame(minHeight: Size.profileRow)
        }
        .accessibilityIdentifier("manage.row.\(title)")
    }
}

#Preview {
    PreviewHost(.s9_5)
}
