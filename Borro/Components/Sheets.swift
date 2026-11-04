import SwiftUI

/// Figma drag handle. Tapping it dismisses the sheet (Figma "Close sheet (tap handle)").
struct SheetHandle: View {
    @Environment(Router.self) private var router

    var body: some View {
        Button {
            router.dismissSheet()
        } label: {
            Capsule()
                .fill(Color.strokeMist)
                .frame(width: Size.sheetHandle.width, height: Size.sheetHandle.height)
                .frame(maxWidth: .infinity, minHeight: Size.hitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close sheet")
        .accessibilityIdentifier("sheetHandle")
    }
}

/// Body of a bottom sheet: handle, optional title row with a close cross, content.
struct SheetContainer<Content: View>: View {
    var title: String?
    var subtitle: String?
    var showsClose = false
    var showsHandle = true
    @ViewBuilder var content: () -> Content

    @Environment(Router.self) private var router

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x12) {
            if showsHandle {
                SheetHandle().padding(.bottom, -Space.x16)
            }
            if let title {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: Space.x4) {
                        Text(title)
                            .font(.b(.s20))
                            .foregroundStyle(Color.ink)
                            .accessibilityAddTraits(.isHeader)
                        if let subtitle {
                            Text(subtitle).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                        }
                    }
                    Spacer(minLength: 0)
                    if showsClose {
                        IconButton(icon: .x, label: "Close") { router.dismissSheet() }
                            .padding(.trailing, -Space.x10)
                    }
                }
            }
            content()
        }
        .padding(.horizontal, Space.gutter)
        .padding(.bottom, Space.x16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.surface)
    }
}

/// Grey scrim plus a card or menu drawn over the current page (overlay frames 1.3, 3.7, 6.7, 6.16).
struct OverlayContainer<Content: View>: View {
    var alignment: Alignment = .center
    var dimmed = true
    @ViewBuilder var content: () -> Content

    @Environment(Router.self) private var router

    var body: some View {
        ZStack(alignment: alignment) {
            (dimmed ? Color.scrim : Color.inkBlack.opacity(0.001))
                .ignoresSafeArea()
                .onTapGesture { router.dismissOverlay() }
                .accessibilityLabel("Dismiss")
                .accessibilityAddTraits(.isButton)
            content()
        }
    }
}
