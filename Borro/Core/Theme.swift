import SwiftUI
import CoreText

// Design tokens read from the Figma Prototype page (file FRdguO9GdzR7f8EeSnaRNR).
// Views use these names only: no raw hex, font sizes or magic numbers.

// MARK: - Colour

extension Color {
    // Ink
    static let ink = Color(rgb: 0x14231C)            // primary text
    static let inkDeep = Color(rgb: 0x12201A)        // headings on cards
    static let inkSecondary = Color(rgb: 0x68766E)   // secondary text
    static let inkMuted = Color(rgb: 0x5E6561)
    static let inkSlate = Color(rgb: 0x23272F)
    static let inkTeal = Color(rgb: 0x162C32)
    static let inkGrey = Color(rgb: 0x708187)
    static let inkFaint = Color(rgb: 0x8B8E95)
    static let inkDisabled = Color(rgb: 0x6B726E)
    static let inkBlack = Color(rgb: 0x000000)
    static let inkNearBlack = Color(rgb: 0x1E1E1E)
    static let inkOlive = Color(rgb: 0x3E4642)
    static let inkStone = Color(rgb: 0x4A514D)

    // Brand
    static let brand = Color(rgb: 0x2341DD)          // buttons, links, liked heart, On loan chip
    static let brandDeep = Color(rgb: 0x1B33B8)      // pill text
    static let brandElectric = Color(rgb: 0x3D49FF)
    static let brandRoyal = Color(rgb: 0x2563EB)
    static let brandSoft = Color(rgb: 0xE7EAFB)
    static let brandMist = Color(rgb: 0xEBEEFC)
    static let brandHaze = Color(rgb: 0xE8EAFF)

    // Surfaces and lines
    static let canvas = Color(rgb: 0xF7F8F6)         // screen background
    static let surface = Color(rgb: 0xFFFFFF)
    static let surfaceSunk = Color(rgb: 0xF6F6F3)
    static let surfaceWarm = Color(rgb: 0xEEEEE9)
    static let peachFill = Color(rgb: 0xFCE3D0)
    static let payNowPurple = Color(rgb: 0x7B2A8C)
    static let track = Color(rgb: 0xEDF0EC)          // progress tracks, muted fills
    static let stroke = Color(rgb: 0xE2E8E1)         // card and field borders
    static let strokeSoft = Color(rgb: 0xE5E8E3)
    static let strokeWarm = Color(rgb: 0xE4E4DF)
    static let strokeMist = Color(rgb: 0xCFD6D3)
    static let strokeCool = Color(rgb: 0xD1D6DB)
    static let toggleOff = Color(rgb: 0xCCCCCC)
    static let greyLight = Color(rgb: 0xACACAC)
    static let greySilver = Color(rgb: 0xB9BCBF)
    static let dotInactive = Color(rgb: 0xB8C4BB)
    static let buttonDisabled = Color(rgb: 0xD5D8DD)
    static let scrim = Color(rgb: 0x14231C).opacity(0.33)

    // Map illustration
    static let mapLand = Color(rgb: 0xE8EEE4)
    static let mapBlock = Color(rgb: 0xD8E1D3)
    static let mapBlockLight = Color(rgb: 0xD5DFCF)
    static let sliderOff = Color(rgb: 0xC9CBD1)

    // Status
    static let pendingFill = Color(rgb: 0xFFF3D9)    // amber chip background
    static let pendingInk = Color(rgb: 0x92600A)     // amber chip text, stars
    static let amber = Color(rgb: 0xF5A524)
    static let successFill = Color(rgb: 0xE8F4EC)
    static let success = Color(rgb: 0x1E8E5A)
    static let successDeep = Color(rgb: 0x0B6B4F)
    static let successMint = Color(rgb: 0xE4F2EC)
    static let tooltipMint = Color(rgb: 0xAEE5C4)
    static let danger = Color(rgb: 0xD64545)
    static let dangerSoft = Color(rgb: 0xE07474)
    static let dangerFill = Color(rgb: 0xFDECE9)

    init(rgb: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((rgb >> 16) & 0xFF) / 255,
                  green: Double((rgb >> 8) & 0xFF) / 255,
                  blue: Double(rgb & 0xFF) / 255,
                  opacity: opacity)
    }
}

// MARK: - Type

/// Inter, bundled under the SIL Open Font Licence (Resources/Fonts/Inter-LICENSE.txt).
enum Inter: String, CaseIterable {
    case regular = "Inter-Regular"
    case medium = "Inter-Medium"
    case semibold = "Inter-SemiBold"
    case bold = "Inter-Bold"
    case extraBold = "Inter-ExtraBold"

    static func registerAll() {
        for face in allCases {
            guard let url = Bundle.main.url(forResource: face.rawValue, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

/// Font sizes used by the Figma frames, named by point size.
enum TypeSize: CGFloat {
    case s9 = 9, s10 = 10, s11 = 11, s12 = 12, s13 = 13, s14 = 14, s14_3 = 14.3, s15 = 15
    case s16 = 16, s17 = 17, s18 = 18, s18_5 = 18.5, s19 = 19, s20 = 20, s21 = 21, s22 = 22
    case s23 = 23, s24 = 24, s25 = 25, s26 = 26, s29 = 29, s40 = 40, s76 = 76

    /// Dynamic Type anchor so every size scales with the user's setting.
    var textStyle: Font.TextStyle {
        switch rawValue {
        case ..<11: return .caption2
        case ..<13: return .caption
        case ..<15: return .footnote
        case ..<17: return .subheadline
        case ..<19: return .body
        case ..<22: return .title3
        case ..<28: return .title2
        default: return .largeTitle
        }
    }
}

extension Font {
    static func inter(_ face: Inter, _ size: TypeSize) -> Font {
        .custom(face.rawValue, size: size.rawValue, relativeTo: size.textStyle)
    }

    // Shorthands for the most used Figma styles (R/M/S/B + size).
    static func r(_ size: TypeSize) -> Font { .inter(.regular, size) }
    static func m(_ size: TypeSize) -> Font { .inter(.medium, size) }
    static func s(_ size: TypeSize) -> Font { .inter(.semibold, size) }
    static func b(_ size: TypeSize) -> Font { .inter(.bold, size) }
}

// MARK: - Spacing, radii, sizes

enum Space {
    static let x2: CGFloat = 2
    static let x3: CGFloat = 3
    static let x4: CGFloat = 4
    static let x5: CGFloat = 5
    static let x6: CGFloat = 6
    static let x7: CGFloat = 7
    static let x8: CGFloat = 8
    static let x9: CGFloat = 9
    static let x10: CGFloat = 10
    static let x12: CGFloat = 12
    static let x14: CGFloat = 14
    static let x16: CGFloat = 16
    static let x18: CGFloat = 18
    static let x20: CGFloat = 20
    static let x24: CGFloat = 24
    static let x28: CGFloat = 28
    static let x32: CGFloat = 32
    static let x40: CGFloat = 40

    /// Side margin: 393 pt frame, 353 pt content.
    static let gutter: CGFloat = 20
    /// Section 4 frames use 361 pt content.
    static let gutterNarrow: CGFloat = 16
    /// Gap between the sticky action area and the tab bar.
    static let aboveTabBar: CGFloat = 18
}

enum Radius {
    static let r2: CGFloat = 2
    static let r4: CGFloat = 4
    static let r5: CGFloat = 5
    static let r6: CGFloat = 6
    static let r8: CGFloat = 8
    static let photo: CGFloat = 10
    static let card: CGFloat = 12
    static let r14: CGFloat = 14
    static let r16: CGFloat = 16
    static let r18: CGFloat = 18
    static let r20: CGFloat = 20
    static let r22: CGFloat = 22
    static let sheet: CGFloat = 24
    static let r25: CGFloat = 25
    static let r30: CGFloat = 30
    static let pill: CGFloat = 99
}

enum Size {
    static let appBar: CGFloat = 64
    static let tabBar: CGFloat = 60
    static let button: CGFloat = 48
    static let buttonSmall: CGFloat = 40
    static let field: CGFloat = 46
    static let hitTarget: CGFloat = 44
    static let icon: CGFloat = 22
    static let iconSmall: CGFloat = 18
    static let iconTiny: CGFloat = 15
    static let avatarTiny: CGFloat = 22
    static let avatarSmall: CGFloat = 32
    static let avatar: CGFloat = 44
    static let avatarLarge: CGFloat = 64
    static let avatarHuge: CGFloat = 96
    static let thumb: CGFloat = 74
    static let requestThumb: CGFloat = 70
    static let tooltipTop: CGFloat = 330
    static let logoAspect: CGFloat = 72.0 / 34.0
    static let bigPill: CGFloat = 36
    static let dayColumn: CGFloat = 96
    static let summaryPhoto: CGFloat = 90
    static let summaryLabel: CGFloat = 76
    static let wheelRow: CGFloat = 32
    static let wheelRowSmall: CGFloat = 22
    static let wheelColumn: CGFloat = 56
    static let selectRow: CGFloat = 52
    static let mapPinStroke: CGFloat = 1.7
    static let meetingMap: CGFloat = 200
    static let bubbleMaxWidth: CGFloat = 250
    static let fab: CGFloat = 50
    static let attachmentTile: CGFloat = 48
    static let checkbox: CGFloat = 22
    static let qr: CGFloat = 180
    static let spinner: CGFloat = 50
    static let payButton: CGFloat = 40
    static let payLogo: CGFloat = 26
    static let stepBar: CGFloat = 3
    static let codeRing: CGFloat = 126
    static let codeRingStroke: CGFloat = 4
    static let moreButton: CGFloat = 27
    static let photoSlot: CGFloat = 210
    static let pagerDot: CGFloat = 24
    static let photoMenu: CGFloat = 220
    static let photoMenuTop: CGFloat = 330
    static let nameField: CGFloat = 48
    static let sheetIcon: CGFloat = 32
    static let photoThumb: CGFloat = 104
    static let recordPhoto: CGFloat = 60
    static let starSize: CGFloat = 24
    static let starHit: CGFloat = 44
    static let profileRow: CGFloat = 46
    static let lockIcon: CGFloat = 24
    static let appIcon: CGFloat = 28
    static let avatarProfile: CGFloat = 70
    static let gaugeStroke: CGFloat = 13
    static let gaugeWidth: CGFloat = 170
    static let iconInfo: CGFloat = 16
    static let factorLabel: CGFloat = 141
    static let factorValue: CGFloat = 34
    static let thumbHeight: CGFloat = 80
    static let thumbSquare: CGFloat = 64
    static let detailPhoto: CGFloat = 145
    static let cardPhoto: CGFloat = 110
    static let seal: CGFloat = 76
    static let sealIcon: CGFloat = 35
    static let avatarMini: CGFloat = 19
    static let avatarMedium: CGFloat = 38
    static let listingPhoto: CGFloat = 98
    static let mapHeight: CGFloat = 250
    static let pinIcon: CGFloat = 17
    static let inputIcon: CGFloat = 20
    static let inputHeight: CGFloat = 48
    static let mapRoadTilt: Double = 8
    static let mapRadiusStroke: CGFloat = 1.5
    static let mapDot: CGFloat = 16
    static let mapDotStroke: CGFloat = 3
    static let calendarCell: CGFloat = 28
    static let filterRow: CGFloat = 48
    static let filterMenuWidth: CGFloat = 250
    static let filterMenuTop: CGFloat = 163
    static let logoWidth: CGFloat = 72
    static let logoHeight: CGFloat = 34
    static let sheetHandle = CGSize(width: 40, height: 5)
    static let stroke: CGFloat = 1
    static let hairline: CGFloat = 0.7
    static let buttonStroke: CGFloat = 1.2
    static let tabIcon: CGFloat = 21
    static let pressedOpacity: Double = 0.75
    static let iconStroke: CGFloat = 1.8
    static let codeBox = CGSize(width: 58, height: 60)
}

enum Shadow {
    static let card = (color: Color.ink.opacity(0.06), radius: CGFloat(12), y: CGFloat(4))
    static let raised = (color: Color.inkBlack.opacity(0.10), radius: CGFloat(20), y: CGFloat(8))
}

extension View {
    func cardShadow() -> some View {
        shadow(color: Shadow.card.color, radius: Shadow.card.radius, y: Shadow.card.y)
    }

    func raisedShadow() -> some View {
        shadow(color: Shadow.raised.color, radius: Shadow.raised.radius, y: Shadow.raised.y)
    }
}
