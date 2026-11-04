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
                if let backTo { router.go(backTo) } else { router.back() }
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
        HStack(spacing: Space.x12) {
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
            IconButton(icon: .heart, tint: .brand, label: "Wishlist") {
                if let heartTarget { router.go(heartTarget) }
            }
            .padding(.trailing, -Space.x10)
        }
        .padding(.horizontal, Space.gutter)
        .frame(minHeight: Size.appBar)
    }
}

struct BorroLogo: View {
    var body: some View {
        PhotoView(photo: .logo, contentMode: .fit)
            .frame(width: Size.logoWidth, height: Size.logoHeight)
            .accessibilityLabel("Borro")
    }
}
