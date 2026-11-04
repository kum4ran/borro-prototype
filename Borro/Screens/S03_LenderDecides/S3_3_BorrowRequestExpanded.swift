import SwiftUI

/// Figma frame "3.3 Thomas · Borrow request expanded" (node 700:198).
struct S3_3_BorrowRequestExpandedView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    private let james = MockData.james

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Borrow Requests", subtitle: "Thomas · 3 new requests", backTo: .s3_2)
        } content: {
            VStack(alignment: .leading, spacing: Space.x10) {
                HStack(spacing: Space.x10) {
                    Avatar(photo: james.photo, size: Size.avatarMedium)
                    VStack(alignment: .leading, spacing: Space.x2) {
                        Text("\(james.name) ✓").font(.b(.s15)).foregroundStyle(Color.ink)
                        Text("\(james.credibility)/100 · \(james.credibilityLabel)  ★ \(james.rating) (\(james.reviewCount) reviews)")
                            .font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    }
                    Spacer()
                    IconView(icon: .info, size: Size.iconInfo).foregroundStyle(Color.brand)
                }
                Text("21 · Singapore Halls · Identity verified ✓").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                HStack(alignment: .top, spacing: Space.x12) {
                    PhotoView(photo: .steamerShirt)
                        .frame(width: Size.requestThumb, height: Size.requestThumb)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
                    VStack(alignment: .leading, spacing: Space.x5) {
                        Text("Garment Steamer").font(.b(.s16)).foregroundStyle(Color.ink)
                        Text(appState.borrowRange).font(.r(.s13)).foregroundStyle(Color.ink)
                        Chip(text: "⚡ URGENT – Borrow Now")
                    }
                }
                CalendarMonth(selected: [appState.borrowStart.day, appState.borrowEnd.day],
                              inRange: appState.borrowDays.subtracting([appState.borrowStart.day, appState.borrowEnd.day]),
                              startsSunday: true, footnote: nil)
                    .padding(-Space.x12)
                    .padding(.vertical, Space.x4)
                HStack(spacing: Space.x16) {
                    PrimaryButton(title: "Accept", identifier: "acceptRequestButton") { router.go(.s3_7) }
                    SecondaryButton(title: "Reject", tint: .danger) {}
                }
                HStack(spacing: Space.x12) {
                    SecondaryButton(title: "Chat") { router.go(.s4_9) }
                    SecondaryButton(title: "View full profile") { router.go(.s3_4) }
                }
            }
            .cardStyle()
        }
    }
}

#Preview {
    PreviewHost(.s3_3)
}
