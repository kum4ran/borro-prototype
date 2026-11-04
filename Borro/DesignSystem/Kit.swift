import SwiftUI

// MARK: - Screen background

struct BBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BColor.bg.ignoresSafeArea())
    }
}

extension View {
    func bBackground() -> some View { modifier(BBackground()) }
}

// MARK: - App bar
//
// Figma: 64pt tall, 20pt side padding, 21/28.4 bold heading, 11/14.9 subtitle,
// 22pt chevron and trailing icons.

struct BAppBar<Trailing: View>: View {
    var title: String
    var subtitle: String?
    var showsBack: Bool = true
    var backAction: (() -> Void)?
    var showsLogo: Bool = false
    @ViewBuilder var trailing: Trailing

    @Environment(\.dismiss) private var dismiss

    init(
        title: String,
        subtitle: String? = nil,
        showsBack: Bool = true,
        showsLogo: Bool = false,
        backAction: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showsBack = showsBack
        self.showsLogo = showsLogo
        self.backAction = backAction
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: BSpace.md) {
            if showsBack {
                Button {
                    if let backAction { backAction() } else { dismiss() }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(BColor.ink)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            } else if showsLogo {
                BLogoMark(height: 26)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BFont.pageTitle)
                    .foregroundStyle(BColor.ink)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(BFont.caption)
                        .foregroundStyle(BColor.inkSecondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, BSpace.screen)
        .frame(height: BMetric.appBarHeight)
        .background(BColor.bg)
    }
}

extension BAppBar where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, showsBack: Bool = true, showsLogo: Bool = false, backAction: (() -> Void)? = nil) {
        self.init(title: title, subtitle: subtitle, showsBack: showsBack, showsLogo: showsLogo, backAction: backAction) {
            EmptyView()
        }
    }
}

/// Plain icon used in app bars.
struct BBarIcon: View {
    var systemName: String
    var size: CGFloat = 20
    var color: Color = BColor.ink

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(color)
            .frame(width: 28, height: 28)
    }
}

// MARK: - Tab bar
//
// Figma: 78pt total, 4 destinations of 90x36, 10/13 semibold labels.

enum AppTab: String, CaseIterable, Hashable {
    case home = "Home"
    case borro = "Borro"
    case lend = "Lend"
    case you = "You"

    var icon: String {
        switch self {
        case .home: return "house"
        case .borro: return BIcon.handshake
        case .lend: return "shippingbox"
        case .you: return "person"
        }
    }

    var filledIcon: String {
        switch self {
        case .home: return "house.fill"
        case .borro: return BIcon.handshakeFilled
        case .lend: return "shippingbox.fill"
        case .you: return "person.fill"
        }
    }

    /// Fallback for symbols missing on older runtimes.
    func safeIcon(selected: Bool) -> String {
        let name = selected ? filledIcon : icon
        if UIImage(systemName: name) != nil { return name }
        switch self {
        case .borro: return selected ? BIcon.handshakeFilled : BIcon.handshake
        default: return name
        }
    }
}

struct BTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(BColor.stroke).frame(height: 1)
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) { selection = tab }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.safeIcon(selected: selection == tab))
                                .font(.system(size: 21, weight: .regular))
                                .frame(height: 24)
                            Text(tab.rawValue)
                                .font(BFont.tabLabel)
                        }
                        .foregroundStyle(selection == tab ? BColor.brand : BColor.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(BColor.surface)
    }
}

// MARK: - Icon fallbacks
//
// Some Figma icons map onto SF Symbols missing on certain runtimes.

enum BIcon {
    static func resolved(_ preferred: String, fallback: String) -> String {
        UIImage(systemName: preferred) != nil ? preferred : fallback
    }

    static var handshake: String { resolved("handshake", fallback: "arrow.left.arrow.right") }
    static var handshakeFilled: String { resolved("handshake.fill", fallback: "arrow.left.arrow.right") }
}

// MARK: - Buttons

enum BButtonKind {
    case primary, secondary, ghost, destructive, orange
}

struct BButtonStyle: ButtonStyle {
    var kind: BButtonKind = .primary
    var height: CGFloat = BMetric.buttonHeight
    var fullWidth: Bool = true
    var pill: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BFont.button)
            .foregroundStyle(foreground)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: height)
            .padding(.horizontal, fullWidth ? 0 : BSpace.xl)
            .background(background(pressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: pill ? BRadius.pill : BRadius.card, style: .continuous))
            .overlay {
                if kind == .secondary {
                    RoundedRectangle(cornerRadius: pill ? BRadius.pill : BRadius.card, style: .continuous)
                        .stroke(BColor.stroke, lineWidth: 1)
                }
            }
            .opacity(configuration.isPressed ? 0.92 : 1)
    }

    private var foreground: Color {
        switch kind {
        case .primary, .destructive, .orange: return .white
        case .secondary: return BColor.ink
        case .ghost: return BColor.brand
        }
    }

    private func background(pressed: Bool) -> Color {
        switch kind {
        case .primary: return pressed ? BColor.brandDark : BColor.brand
        case .secondary: return pressed ? BColor.surfaceAlt : BColor.surface
        case .ghost: return pressed ? BColor.brandSoft : .clear
        case .destructive: return pressed ? BColor.danger.opacity(0.85) : BColor.danger
        case .orange: return pressed ? BColor.orange.opacity(0.85) : BColor.orange
        }
    }
}

struct BButtonLabel: View {
    var title: String
    var icon: String?
    var trailingIcon: String?

    init(_ title: String, icon: String? = nil, trailingIcon: String? = nil) {
        self.title = title
        self.icon = icon
        self.trailingIcon = trailingIcon
    }

    var body: some View {
        HStack(spacing: 6) {
            if let icon { Image(systemName: icon).font(.system(size: 15, weight: .semibold)) }
            Text(title)
            if let trailingIcon { Image(systemName: trailingIcon).font(.system(size: 13, weight: .semibold)) }
        }
    }
}

struct BIconButton: View {
    var systemName: String
    var size: CGFloat = 40
    var background: Color = BColor.surface
    var foreground: Color = BColor.ink
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: size, height: size)
                .background(background)
                .clipShape(Circle())
                .overlay { Circle().stroke(BColor.stroke, lineWidth: 1) }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fields

struct BField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String?
    var keyboard: UIKeyboardType = .default
    var axis: Axis = .horizontal

    var body: some View {
        HStack(spacing: BSpace.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(BColor.inkSecondary)
            }
            if axis == .vertical {
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(BFont.body)
                    .lineLimit(3, reservesSpace: true)
            } else {
                TextField(placeholder, text: $text)
                    .font(BFont.body)
                    .keyboardType(keyboard)
            }
        }
        .padding(.horizontal, BSpace.lg)
        .frame(minHeight: BMetric.fieldHeight)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.pill, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.pill, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 1)
        }
    }
}

/// Search row: pill field + blue Search button.
struct BSearchRow: View {
    @Binding var text: String
    var placeholder: String = "What do you need?"
    var buttonTitle: String = "Search"
    var onSearch: () -> Void

    var body: some View {
        HStack(spacing: BSpace.sm) {
            HStack(spacing: BSpace.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(BColor.ink)
                TextField(placeholder, text: $text)
                    .font(BFont.body)
                    .foregroundStyle(BColor.ink)
                    .submitLabel(.search)
                    .onSubmit(onSearch)
            }
            .padding(.horizontal, BSpace.lg)
            .frame(height: BMetric.fieldHeight)
            .background(BColor.surface)
            .clipShape(Capsule())
            .overlay { Capsule().stroke(BColor.stroke, lineWidth: 1) }

            Button(action: onSearch) {
                Text(buttonTitle)
                    .font(BFont.semibold(13))
                    .foregroundStyle(.white)
                    .frame(width: 78, height: BMetric.fieldHeight)
                    .background(BColor.brand)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Chips / pills

struct BChip: View {
    var title: String
    var icon: String?
    var selected: Bool = false
    var tint: Color = BColor.brand
    var body: some View {
        HStack(spacing: 5) {
            if let icon { Image(systemName: icon).font(.system(size: 11, weight: .semibold)) }
            Text(title).font(BFont.captionSemibold)
        }
        .foregroundStyle(selected ? .white : BColor.ink)
        .padding(.horizontal, 12)
        .frame(height: 30)
        .background(selected ? tint : BColor.surface)
        .clipShape(Capsule())
        .overlay { Capsule().stroke(selected ? .clear : BColor.stroke, lineWidth: 1) }
    }
}

struct BFilterChip: View {
    var title: String
    var value: String?
    var icon: String?
    var hasChevron: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 5) {
                if let icon { Image(systemName: icon).font(.system(size: 11, weight: .semibold)) }
                Text(title).font(BFont.captionSemibold)
                if let value {
                    Text(value).font(BFont.caption).foregroundStyle(BColor.inkSecondary)
                }
                if hasChevron {
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold))
                }
            }
            .foregroundStyle(BColor.ink)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(BColor.surface)
            .clipShape(Capsule())
            .overlay { Capsule().stroke(BColor.stroke, lineWidth: 1) }
        }
        .buttonStyle(.plain)
    }
}

/// "⚡ Need it Now" urgency switch from the Discover screen.
struct BUrgencyToggle: View {
    var isOn: Bool
    var onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isOn ? .white : BColor.orange)
                Text("Need it Now")
                    .font(BFont.captionSemibold)
                    .foregroundStyle(isOn ? .white : BColor.ink)
                Circle()
                    .fill(isOn ? .white : BColor.surface)
                    .frame(width: 12, height: 12)
                    .overlay { Circle().stroke(isOn ? .clear : BColor.inkSecondary, lineWidth: 1.2) }
            }
            .padding(.horizontal, 12)
            .frame(height: 28)
            .background(isOn ? BColor.orange : BColor.chipMuted)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct BTag: View {
    var text: String
    var icon: String?
    var tint: Color = BColor.brand
    var soft: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon).font(.system(size: 9, weight: .bold)) }
            Text(text).font(BFont.microSemibold)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(soft ? tint.opacity(0.10) : tint)
        .clipShape(Capsule())
    }
}

// MARK: - Section header

struct BSectionHeader: View {
    var title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(BFont.sectionTitle)
                .foregroundStyle(BColor.ink)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle).font(BFont.captionSemibold).foregroundStyle(BColor.brand)
                }
                .buttonStyle(.plain)
            }
            if let subtitle {
                Text(subtitle).font(BFont.caption).foregroundStyle(BColor.inkSecondary)
            }
        }
    }
}

// MARK: - Ratings

struct BStars: View {
    var rating: Double
    var reviews: Int?
    var compact: Bool = true

    var body: some View {
        HStack(spacing: 3) {
            Text("★")
                .font(BFont.captionSemibold)
                .foregroundStyle(BColor.star)
            Text(reviews != nil ? String(format: "%.1f", rating) : String(format: "%.1f", rating))
                .font(BFont.caption)
                .foregroundStyle(BColor.ink)
            if let reviews, !compact {
                Text("(\(reviews) reviews)")
                    .font(BFont.caption)
                    .foregroundStyle(BColor.ink)
            } else if let reviews {
                Text("(\(reviews) reviews)")
                    .font(BFont.caption)
                    .foregroundStyle(BColor.ink)
            }
        }
    }
}

struct BStarPicker: View {
    @Binding var rating: Int
    var size: CGFloat = 34

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { index in
                Button {
                    rating = index
                } label: {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.system(size: size, weight: .regular))
                        .foregroundStyle(index <= rating ? BColor.brand : BColor.inkTertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Owner row

struct BOwnerRow: View {
    var person: Person
    var size: CGFloat = 22
    var showsChevron: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            BAvatarView(photo: person.photo, initials: person.initials, size: size)
            Text(person.name)
                .font(BFont.captionSemibold)
                .foregroundStyle(BColor.ink)
                .lineLimit(1)
            if person.verified {
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(BColor.brand)
            }
        }
    }
}

// MARK: - Marketplace item card
//
// Figma: 170.5 x 251, r=12, white, 9pt inner padding, 22pt owner row,
// 152.5 x 98 photo, 12/16.2 bold title, 11/14.9 rating, 10/13.5 location,
// availability block with 13/18 semibold blue dates.

struct BItemCard: View {
    var item: Item
    var saved: Bool = false
    var onSave: (() -> Void)?
    var onTap: (() -> Void)?
    var showsDistance: Bool = false

    private let innerWidth = BMetric.cardWidth - BSpace.cardInner * 2   // 152.5

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ownerRow.frame(height: 22)
                Spacer(minLength: 6).frame(height: 6)
                BImageView(photo: item.photo, cornerRadius: BRadius.photo)
                    .frame(width: innerWidth, height: 98)
                    .clipped()
                Spacer(minLength: 6).frame(height: 6)
                titleRow.frame(height: 16)
                Spacer(minLength: 3).frame(height: 3)
                BStars(rating: item.rating, reviews: item.reviewCount)
                    .frame(height: 15, alignment: .leading)
                Spacer(minLength: 3).frame(height: 3)
                Text(item.location)
                    .font(BFont.micro)
                    .foregroundStyle(BColor.inkSecondary)
                    .lineLimit(1)
                    .frame(height: 14, alignment: .leading)
                Spacer(minLength: 2).frame(height: 2)
                availability.frame(height: 33, alignment: .topLeading)
                Spacer(minLength: 0)
            }
            .frame(width: innerWidth, alignment: .leading)
            .padding(BSpace.cardInner)
            .frame(width: BMetric.cardWidth, height: 251, alignment: .topLeading)
            .background(BColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var ownerRow: some View {
        HStack(spacing: 5) {
            BAvatarView(photo: item.owner.photo, initials: item.owner.initials, size: 22)
            Text(item.owner.name)
                .font(BFont.captionSemibold)
                .foregroundStyle(BColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(BColor.brand)
            Spacer(minLength: 0)
        }
        .frame(width: innerWidth, alignment: .leading)
    }

    private var titleRow: some View {
        HStack(spacing: 4) {
            Text(item.title)
                .font(BFont.cardTitle)
                .foregroundStyle(BColor.ink)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
            if let onSave {
                Button(action: onSave) {
                    Image(systemName: saved ? "heart.fill" : "heart")
                        .font(.system(size: 12))
                        .foregroundStyle(saved ? BColor.brand : BColor.inkSecondary)
                        .frame(width: 15, height: 15)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: innerWidth, alignment: .leading)
    }

    private var availability: some View {
        VStack(alignment: .leading, spacing: 2) {
            if showsDistance {
                Text("⚡ \(item.distance) · \(item.availability.lowercased())")
                    .font(BFont.microSemibold)
                    .foregroundStyle(BColor.warning)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            } else {
                Text(item.availability)
                    .font(BFont.microSemibold)
                    .foregroundStyle(BColor.inkSecondary)
                Text(item.availabilityDateLabel)
                    .font(BFont.labelSemibold)
                    .foregroundStyle(BColor.brand)
            }
        }
        .frame(width: innerWidth, alignment: .leading)
    }
}

extension Item {
    /// Availability string as shown on the discovery cards.
    var availabilityDateLabel: String {
        if availability == "Available now" { return "available now" }
        switch id {
        case "jbl": return "17–25 Oct 2026"
        case "projector": return "16–23 Oct 2026"
        case "screen": return "18–20 Oct 2026"
        case "football": return "17–21 Oct 2026"
        case "steamer": return "17–19 Oct 2026"
        default: return "17–19 Oct 2026"
        }
    }
}

// MARK: - Rows & dividers

struct BDivider: View {
    var color: Color = BColor.divider
    var body: some View {
        Rectangle().fill(color).frame(height: 1)
    }
}

struct BMenuRow: View {
    var icon: String?
    var title: String
    var subtitle: String?
    var value: String?
    var showsChevron: Bool = true
    var tint: Color = BColor.ink

    var body: some View {
        HStack(spacing: BSpace.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 22)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(BFont.body).foregroundStyle(tint)
                if let subtitle {
                    Text(subtitle).font(BFont.caption).foregroundStyle(BColor.inkSecondary)
                }
            }
            Spacer(minLength: 0)
            if let value {
                Text(value).font(BFont.caption).foregroundStyle(BColor.inkSecondary)
            }
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(BColor.inkTertiary)
            }
        }
        .padding(.horizontal, BSpace.lg)
        .frame(minHeight: 52)
    }
}

struct BEmptyState: View {
    var icon: String
    var title: String
    var message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: BSpace.md) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(BColor.brand)
                .frame(width: 68, height: 68)
                .background(BColor.brandSoft)
                .clipShape(Circle())
            VStack(spacing: 4) {
                Text(title).font(BFont.bodySemibold).foregroundStyle(BColor.ink)
                Text(message)
                    .font(BFont.caption)
                    .foregroundStyle(BColor.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle, let action {
                Button(action: action) { BButtonLabel(actionTitle) }
                    .buttonStyle(BButtonStyle(fullWidth: false))
                    .padding(.top, 4)
            }
        }
        .padding(BSpace.xxl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Sheet chrome

struct BSheetHandle: View {
    var body: some View {
        Capsule()
            .fill(BColor.stroke)
            .frame(width: 40, height: 4)
            .padding(.top, BSpace.sm)
    }
}

struct BSheetHeader: View {
    var title: String
    var subtitle: String?
    var onClose: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: BSpace.md) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(BFont.sheetTitle).foregroundStyle(BColor.ink)
                if let subtitle {
                    Text(subtitle).font(BFont.caption).foregroundStyle(BColor.inkSecondary)
                }
            }
            Spacer()
            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(BColor.ink)
                        .frame(width: 28, height: 28)
                        .background(BColor.surfaceAlt)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Standard bottom-sheet surface used by all pop-ups.
struct BSheetSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            BSheetHandle()
            content
                .padding(BSpace.screen)
        }
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.sheet, style: .continuous))
        .bShadow(3)
    }
}

// MARK: - Misc

struct BKeyValueRow: View {
    var label: String
    var value: String
    var valueColor: Color = BColor.ink

    var body: some View {
        HStack {
            Text(label).font(BFont.body).foregroundStyle(BColor.inkSecondary)
            Spacer()
            Text(value).font(BFont.bodyMedium).foregroundStyle(valueColor)
        }
    }
}

struct BPillSelector<Item: Hashable>: View {
    var items: [Item]
    var title: (Item) -> String
    @Binding var selection: Item

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { selection = item }
                } label: {
                    Text(title(item))
                        .font(BFont.captionSemibold)
                        .foregroundStyle(selection == item ? .white : BColor.inkSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(selection == item ? BColor.brand : .clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(BColor.chipMuted)
        .clipShape(Capsule())
    }
}

/// Circular progress / check bubble used by confirmations.
struct BStatusBubble: View {
    var systemName: String
    var tint: Color = BColor.brand
    var size: CGFloat = 64

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.12))
            .clipShape(Circle())
    }
}
