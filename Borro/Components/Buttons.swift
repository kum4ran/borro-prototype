import SwiftUI

/// Full-width pill: blue fill, white Inter Bold 14. 48 pt tall, 353 pt wide in a 393 pt frame.
struct PrimaryButton: View {
    let title: String
    var enabled = true
    var fill: Color = .brand
    var identifier: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.b(.s14))
                .foregroundStyle(enabled ? Color.surface : Color.inkDisabled)
                .frame(maxWidth: .infinity, minHeight: Size.button)
                .background(enabled ? fill : Color.buttonDisabled, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
        .disabled(!enabled)
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier ?? title)
    }
}

/// Outline pill: white fill, 1.2 pt blue (or red) border, blue Inter Bold 14.
struct SecondaryButton: View {
    let title: String
    var tint: Color = .brand
    var identifier: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.b(.s14))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity, minHeight: Size.button)
                .background(Color.surface, in: Capsule())
                .overlay(Capsule().strokeBorder(tint, lineWidth: Size.buttonStroke))
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(title)
        .accessibilityIdentifier(identifier ?? title)
    }
}

/// Grey pill that looks disabled but still responds (Figma wires some of these).
struct MutedButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.b(.s14))
                .foregroundStyle(Color.inkSecondary)
                .frame(maxWidth: .infinity, minHeight: Size.button)
                .background(Color.track, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(title)
    }
}

/// Text link in brand blue.
struct LinkButton: View {
    let title: String
    var font: Font = .b(.s13)
    var tint: Color = .brand
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundStyle(tint)
                .frame(minHeight: Size.hitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

/// Icon-only button with a 44 pt hit target.
struct IconButton: View {
    let icon: Icon
    var size: CGFloat = Size.icon
    var tint: Color = .ink
    var filled = false
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            IconView(icon: icon, size: size, filled: filled)
                .foregroundStyle(tint)
                .frame(minWidth: Size.hitTarget, minHeight: Size.hitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

/// Dims slightly while pressed, like Figma's prototype hover.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? Size.pressedOpacity : 1)
    }
}

/// Makes any view a full-area button (cards, rows) with a plain style.
struct TapArea<Label: View>: View {
    let accessibilityLabel: String
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            label().contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}
