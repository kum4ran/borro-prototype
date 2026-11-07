import SwiftUI

/// Figma "App bar" with a back chevron: 64 pt tall, title Inter Bold 21, optional subtitle.
struct BackAppBar<Trailing: View>: View {
    let title: String
    var subtitle: String?
    /// Explicit Figma target for the chevron; nil means "back one screen".
    var backTo: Screen?
    @ViewBuilder var trailing: () -> Trailing

    @Environment(Router.self) private var router

    var body: some View {
        HStack(alignment: .center, spacing: Space.x12) {
            IconButton(icon: .chevronLeft, label: "Back") {
                if !router.path.isEmpty {
                    router.back()
                } else if let backTo {
                    router.go(backTo)
                } else {
                    router.back()
                }
            }
            .padding(.leading, -Space.x12)
            .padding(.trailing, -Space.x10)
            .accessibilityIdentifier("backButton")

            VStack(alignment: .leading, spacing: Space.x2) {
                Text(title)
                    .font(.b(.s21))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(Size.titleMinScale)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle {
                    Text(subtitle)
                        .font(.r(.s11))
                        .foregroundStyle(Color.inkSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(Size.titleMinScale)
                }
            }
            Spacer(minLength: 0)
            trailing()
            if Trailing.self == EmptyView.self {
                UserSwitcherButton()
            }
        }
        .padding(.horizontal, Space.gutter)
        .frame(minHeight: Size.appBar)
    }
}

extension BackAppBar where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, backTo: Screen? = nil) {
        self.init(title: title, subtitle: subtitle, backTo: backTo) { EmptyView() }
    }
}

/// Figma "App bar" on tab roots: Borro logo, optional big title (Inter Bold 25), wishlist heart.
struct BrandAppBar: View {
    var title: String?
    /// Figma only wires the heart on some frames.
    var heartTarget: Screen?

    @Environment(Router.self) private var router

    var body: some View {
        HStack(spacing: Space.x10) {
            BorroLogo()
            if let title {
                Text(title)
                    .font(.b(.s25))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(Size.titleMinScale)
                    .accessibilityAddTraits(.isHeader)
            }
            Spacer(minLength: 0)
            UserSwitcherButton()
            if heartTarget != nil {
                IconButton(icon: .heart, tint: .brand, label: "Wishlist") {
                    if let heartTarget { router.go(heartTarget) }
                }
                .padding(.trailing, -Space.x6)
            }
        }
        .padding(.horizontal, Space.gutter)
        .frame(minHeight: Size.appBar)
    }
}

/// Quick user switcher in the top right: Yellow/Amber for Borrower (James), Red for Lender (Thomas).
struct UserSwitcherButton: View {
    @Environment(AppState.self) private var appState

    var isThomas: Bool { appState.activeUser.id == "thomas" }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                if isThomas {
                    appState.setActiveUser(MockData.james)
                } else {
                    appState.setActiveUser(MockData.thomas)
                }
            }
        } label: {
            HStack(spacing: Space.x4) {
                Avatar(photo: appState.activeUser.photo, size: Size.avatarTiny)
                VStack(alignment: .leading, spacing: 0) {
                    Text(appState.activeUser.name)
                        .font(.b(.s11))
                        .foregroundStyle(isThomas ? Color.danger : Color.brand)
                    Text(isThomas ? "Lender" : "Borrower")
                        .font(.s(.s9))
                        .foregroundStyle(isThomas ? Color.danger : Color.pendingInk)
                }
                IconView(icon: .moreHorizontal, size: Size.iconTiny)
                    .foregroundStyle(Color.inkSecondary)
            }
            .padding(.horizontal, Space.x6)
            .padding(.vertical, Space.x4)
            .background(isThomas ? Color.dangerFill : Color.pendingFill, in: Capsule())
            .overlay(Capsule().strokeBorder(isThomas ? Color.danger.opacity(0.3) : Color.pendingInk.opacity(0.3), lineWidth: Size.stroke))
            .shadow(color: Color.black.opacity(0.04), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Active user: \(appState.activeUser.name). Tap to switch role.")
    }
}

struct BorroLogo: View {
    var body: some View {
        PhotoView(photo: .logo, contentMode: .fit)
            .frame(width: Size.logoWidth, height: Size.logoHeight)
            .accessibilityLabel("Borro")
    }
}
