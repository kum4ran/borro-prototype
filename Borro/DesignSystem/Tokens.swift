import SwiftUI

// MARK: - Borro design tokens
//
// Values read directly from the Figma file (Borro, node page "Screens").
// Every screen in the prototype uses these tokens, never raw hex.

enum BColor {
    // Surfaces
    static let bg          = Color(hex: 0xF7F8F6)   // app background
    static let surface     = Color.white
    static let surfaceAlt  = Color(hex: 0xEEF1EC)
    static let chipMuted   = Color(hex: 0xE8EEE4)

    // Ink
    static let ink         = Color(hex: 0x14231C)
    static let inkSecondary = Color(hex: 0x68766E)
    static let inkTertiary = Color(hex: 0x9AA39C)
    static let inkInverse  = Color.white

    // Brand
    static let brand       = Color(hex: 0x2341DD)
    static let brandDark   = Color(hex: 0x1B33B0)
    static let brandSoft   = Color(hex: 0xE9EDFF)
    static let brandTint   = Color(hex: 0xD7DEFF)

    // Lines
    static let stroke      = Color(hex: 0xE2E8E1)
    static let strokeBlue  = Color(hex: 0xDCE7F2)
    static let divider     = Color(hex: 0xE8ECE7)

    // Semantic
    static let success     = Color(hex: 0x1E8A4C)
    static let successSoft = Color(hex: 0xE4F5EA)
    static let warning     = Color(hex: 0xA46604)
    static let warningSoft = Color(hex: 0xFFF3D9)
    static let orange      = Color(hex: 0xFF8D28)
    static let orangeSoft  = Color(hex: 0xFFECD6)
    static let danger      = Color(hex: 0xC8372F)
    static let dangerSoft  = Color(hex: 0xFDECEA)
    static let gold        = Color(hex: 0xA46604)
    static let star        = Color(hex: 0x14231C)
}

// MARK: - Spacing

enum BSpace {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32

    static let screen: CGFloat = 20     // horizontal page padding (393 - 353)
    static let cardInner: CGFloat = 9   // marketplace card inner padding
}

// MARK: - Radii

enum BRadius {
    static let photo: CGFloat = 10
    static let card: CGFloat = 12
    static let field: CGFloat = 14
    static let sheet: CGFloat = 24
    static let pill: CGFloat = 99
    static let phone: CGFloat = 28
}

// MARK: - Fixed metrics from Figma

enum BMetric {
    static let screenWidth: CGFloat = 393
    static let appBarHeight: CGFloat = 64
    static let tabBarHeight: CGFloat = 78
    static let fieldHeight: CGFloat = 46
    static let buttonHeight: CGFloat = 46
    static let rowHeight: CGFloat = 56
    static let gridGap: CGFloat = 12
    static let cardWidth: CGFloat = (393 - 20 * 2 - 12) / 2   // 170.5
}

// MARK: - Helpers

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

extension View {
    func bShadow(_ level: Int = 1) -> some View {
        switch level {
        case 0:
            return AnyView(self)
        case 2:
            return AnyView(shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 8))
        case 3:
            return AnyView(shadow(color: Color.black.opacity(0.18), radius: 30, x: 0, y: 14))
        default:
            return AnyView(shadow(color: Color(hex: 0x14231C).opacity(0.06), radius: 12, x: 0, y: 4))
        }
    }
}
