import SwiftUI

/// Figma frame "11.1 James · Item details · Borrow Later" (node 708:2691).
struct S11_1_ItemDetailsBorrowLaterView: View {
    @Environment(Router.self) private var router
    var body: some View {
        BorrowLaterSheet(subtitle: "Tap every day you can hand it over.", onNext: { router.go(.s11_2) })
    }
}

#Preview {
    PreviewHost(.s11_1)
}
