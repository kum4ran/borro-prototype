import SwiftUI

/// Figma frame "8.9 James · Profile" (node 691:7051). You tab root.
/// Credibility stays at the Figma value (72); Figma shows no change after the reviews.
struct S8_9_ProfileView: View {
    @Environment(Router.self) private var router
    private let james = MockData.james

    private var rows: [(Icon, String, Screen?)] {
        [(.package, "My Listings", .s9_1), (.handshake, "My Borrowing", .s2_4), (.heart, "Wishlist", .s11_4),
         (.star, "Reviews", .s3_6), (.creditCard, "Payment methods", nil), (.settings, "Settings", nil), (.circleHelp, "Help", nil)]
    }

    var body: some View {
        ScreenScaffold {
            HStack { BorroLogo(); Spacer() }
                .padding(.horizontal, Space.gutter)
                .frame(minHeight: Size.appBar)
        } content: {
            ProfileHeader(user: james, name: james.fullName)
            Text(james.bio).font(.r(.s14)).foregroundStyle(Color.inkSecondary)
            VStack(spacing: Space.x12) {
                CredibilityGauge(score: james.credibility, label: james.credibilityLabel)
                Text("\(james.credibility)/100 · \(james.credibilityLabel) · Keep sharing thoughtfully.")
                    .font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle()
            VStack(spacing: 0) {
                ForEach(rows, id: \.1) { row in
                    TapArea(accessibilityLabel: row.1) {
                        if let target = row.2 { router.go(target) }
                    } label: {
                        HStack(spacing: Space.x12) {
                            IconView(icon: row.0, size: Size.iconSmall).foregroundStyle(Color.brand)
                            Text(row.1).font(.r(.s15)).foregroundStyle(Color.ink)
                            Spacer()
                            IconView(icon: .chevronRight, size: Size.iconSmall).foregroundStyle(Color.ink)
                        }
                        .frame(minHeight: Size.profileRow)
                    }
                }
            }
            .cardStyle(padding: Space.x12)
        }
    }
}

#Preview {
    PreviewHost(.s8_9)
}
