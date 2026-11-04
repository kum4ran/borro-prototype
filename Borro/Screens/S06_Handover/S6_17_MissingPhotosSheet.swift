import SwiftUI

/// Figma frame "6.17 James · Missing photos (sheet)" (node 703:2342).
struct S6_17_MissingPhotosSheetView: View {
    var body: some View {
        InfoSheet(title: "Missing photos",
                  message: "Remember to always take clear picture so that lenders are able to assess the quality clearly",
                  alert: "There is an incomplete upload for your collection",
                  done: .s6_14)
    }
}

#Preview {
    PreviewHost(.s6_17)
}
