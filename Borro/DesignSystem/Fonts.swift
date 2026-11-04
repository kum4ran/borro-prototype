import SwiftUI
import UIKit
import CoreText

// MARK: - Inter registration
//
// Figma uses Inter throughout. The TTFs ship in the bundle and are registered
// with CoreText at launch, so no Info.plist font entries are needed.

enum BFonts {
    private static var registered = false

    static func registerIfNeeded() {
        guard !registered else { return }
        registered = true
        for name in ["Inter-Regular", "Inter-Medium", "Inter-SemiBold", "Inter-Bold", "Inter-ExtraBold"] {
            let url = Bundle.main.url(forResource: name, withExtension: "ttf")
                ?? Bundle.main.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
                ?? Bundle.main.url(forResource: name, withExtension: "otf")
            guard let url else {
                #if DEBUG
                print("[BFonts] missing \(name).ttf in bundle")
                #endif
                continue
            }
            var error: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        }
    }
}

// MARK: - Type ramp (sizes lifted from the Figma text styles)

enum BFont {
    static func regular(_ size: CGFloat) -> Font { .custom("Inter-Regular", size: size) }
    static func medium(_ size: CGFloat) -> Font { .custom("Inter-Medium", size: size) }
    static func semibold(_ size: CGFloat) -> Font { .custom("Inter-SemiBold", size: size) }
    static func bold(_ size: CGFloat) -> Font { .custom("Inter-Bold", size: size) }
    static func extraBold(_ size: CGFloat) -> Font { .custom("Inter-ExtraBold", size: size) }

    // Roles
    static let display   = extraBold(28)
    static let pageTitle = bold(21)        // app bar heading
    static let screenTitle = bold(28)
    static let sectionTitle = bold(18)
    static let sheetTitle = bold(18)
    static let listTitle = bold(14)
    static let cardTitle = bold(12)
    static let body      = regular(14)
    static let bodyMedium = medium(14)
    static let bodySemibold = semibold(14)
    static let label     = medium(12)
    static let labelSemibold = semibold(12)
    static let labelBold = bold(12)
    static let caption   = regular(11)
    static let captionMedium = medium(11)
    static let captionSemibold = semibold(11)
    static let captionBold = bold(11)
    static let micro     = regular(10)
    static let microMedium = medium(10)
    static let microSemibold = semibold(10)
    static let microBold = bold(10)
    static let button    = semibold(14)
    static let tabLabel  = semibold(10)
}

// MARK: - Small text helpers

extension View {
    func bText(_ font: Font, _ color: Color = BColor.ink) -> some View {
        self.font(font).foregroundStyle(color)
    }
}
