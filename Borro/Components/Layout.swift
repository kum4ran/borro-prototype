import SwiftUI

/// Standard Figma page: fixed app bar, scrolling content with 20 pt gutters,
/// optional sticky action area that sits 18 pt above the tab bar.
struct ScreenScaffold<Header: View, Content: View, Actions: View>: View {
    var contentSpacing: CGFloat = Space.x12
    var topPadding: CGFloat = Space.x8
    var gutter: CGFloat = Space.gutter
    @ViewBuilder var header: () -> Header
    @ViewBuilder var content: () -> Content
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: contentSpacing) {
                content()
            }
            .padding(.horizontal, gutter)
            .padding(.top, topPadding)
            .padding(.bottom, Space.aboveTabBar)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: 0) {
            header().background(Color.canvas)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if Actions.self != EmptyView.self {
                VStack(spacing: Space.x8) { actions() }
                    .padding(.horizontal, gutter)
                    .padding(.top, Space.x10)
                    .padding(.bottom, Space.aboveTabBar)
                    .background(Color.canvas)
            }
        }
        .background(Color.canvas)
    }
}

extension ScreenScaffold where Actions == EmptyView {
    init(contentSpacing: CGFloat = Space.x12, topPadding: CGFloat = Space.x8, gutter: CGFloat = Space.gutter,
         @ViewBuilder header: @escaping () -> Header, @ViewBuilder content: @escaping () -> Content) {
        self.init(contentSpacing: contentSpacing, topPadding: topPadding, gutter: gutter,
                  header: header, content: content) { EmptyView() }
    }
}

// MARK: - Cards

extension View {
    /// Figma "Card": white, 12 pt radius, 0.7 pt #E2E8E1 border, soft shadow.
    func cardStyle(padding: CGFloat = Space.x12, radius: CGFloat = Radius.card, shadow: Bool = true) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(Color.stroke, lineWidth: Size.hairline))
            .modifier(OptionalShadow(on: shadow))
    }

    /// Tinted panel (info boxes, notes).
    func panel(_ fill: Color, padding: CGFloat = Space.x12, radius: CGFloat = Radius.card) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill, in: RoundedRectangle(cornerRadius: radius))
    }
}

private struct OptionalShadow: ViewModifier {
    let on: Bool
    func body(content: Content) -> some View {
        if on { content.cardShadow() } else { content }
    }
}

// MARK: - Chips

/// Small pill label, Inter Bold 11.
struct Chip: View {
    let text: String
    var fill: Color = .pendingFill
    var ink: Color = .pendingInk
    var font: Font = .b(.s11)

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(ink)
            .padding(.horizontal, Space.x10)
            .padding(.vertical, Space.x5)
            .background(fill, in: Capsule())
    }
}

/// Borrowing status chip, colours from the Figma "Borro status" variables.
struct StatusChip: View {
    let status: BorrowStatus

    var body: some View {
        Chip(text: status.rawValue, fill: status.chipFill, ink: status.chipInk)
            .accessibilityLabel("Status: \(status.rawValue)")
            .accessibilityIdentifier("statusChip")
    }
}

extension BorrowStatus {
    var chipFill: Color {
        switch tone {
        case .amber: return .pendingFill
        case .blue: return .brandMist
        case .green: return .successFill
        }
    }

    var chipInk: Color {
        switch tone {
        case .amber: return .pendingInk
        case .blue: return .brand
        case .green: return .success
        }
    }
}

// MARK: - Text helpers

struct SectionTitle: View {
    let text: String
    var font: Font = .b(.s18)
    var color: Color = .inkBlack

    var body: some View {
        Text(text).font(font).foregroundStyle(color).accessibilityAddTraits(.isHeader)
    }
}

/// "Label  ·  value" row used on summary cards.
struct DotRow: View {
    let label: String
    let value: String

    var body: some View {
        (Text("\(label)  ·  ").foregroundStyle(Color.inkSecondary) + Text(value).font(.b(.s13)).foregroundStyle(Color.ink))
            .font(.r(.s13))
            .frame(maxWidth: .infinity, minHeight: Space.x24, alignment: .leading)
    }
}

/// Left label, right value, Inter 13.
struct KeyValueRow: View {
    let key: String
    let value: String
    var valueFont: Font = .s(.s13)

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(key).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            Spacer(minLength: Space.x12)
            Text(value).font(valueFont).foregroundStyle(Color.ink).multilineTextAlignment(.trailing)
        }
    }
}

struct Divider1: View {
    var color: Color = .stroke
    var body: some View { Rectangle().fill(color).frame(height: Size.stroke) }
}
