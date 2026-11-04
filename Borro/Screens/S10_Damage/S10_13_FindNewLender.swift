import SwiftUI

/// Figma frame "10.13 James · Find new lender" (node 708:2598).
struct S10_13_FindNewLenderView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Find new lender", subtitle: "My Borrowing · Steamer replacement", backTo: .s10_12)
        } content: {
            InfoBanner(icon: .info, title: "Thomas cancelled", message: "Unavailable due to personal circumstances.")
            Text("⌖ Recommended for your dates").font(.b(.s15)).foregroundStyle(Color.ink)
            ForEach(MockData.alternatives, id: \.user.id) { alt in
                TapArea(accessibilityLabel: "\(alt.user.name), request") { router.go(.s2_3) } label: {
                    HStack(spacing: Space.x10) {
                        VStack(alignment: .leading, spacing: Space.x6) {
                            HStack(spacing: Space.x6) {
                                Avatar(photo: alt.user.photo, size: Size.avatarSmall)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("\(alt.user.name) · \(alt.distance)").font(.b(.s13)).foregroundStyle(Color.ink)
                                    Text("\(alt.user.credibility)/100 · \(alt.user.credibilityLabel)").font(.r(.s11)).foregroundStyle(Color.brand)
                                }
                                Spacer()
                                Text("⌖ Pinned").font(.r(.s10)).foregroundStyle(Color.brand)
                            }
                            HStack(spacing: Space.x8) {
                                PhotoView(photo: .listPhoto5).frame(width: Size.avatar, height: Size.avatar)
                                    .clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                                VStack(alignment: .leading, spacing: Space.x2) {
                                    Text("Garment Steamer").font(.b(.s12)).foregroundStyle(Color.ink)
                                    Text("18–19 Oct · \(Scenario.depositAmount) deposit").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                                }
                                Spacer()
                                Chip(text: "Request", fill: .brand, ink: .surface, font: .b(.s13))
                            }
                        }
                    }
                    .cardStyle()
                }
                .accessibilityIdentifier("recommended.\(alt.user.id)")
            }
            PrimaryButton(title: "Search for other") {}
            Text("New results nearby").font(.b(.s15)).foregroundStyle(Color.ink)
            VStack(alignment: .leading, spacing: Space.x2) {
                Text("Portable steamer · Daniel").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("780 m · Available 18–19 Oct 2026").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle()
        }
    }
}

#Preview {
    PreviewHost(.s10_13)
}
