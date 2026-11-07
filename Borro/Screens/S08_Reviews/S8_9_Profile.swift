import SwiftUI

/// Figma frame "8.9 James · Profile" (node 691:7051). You tab root.
/// Credibility stays at the Figma value (72); Figma shows no change after the reviews.
struct S8_9_ProfileView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @State private var showingAccountSwitcher = false

    private var user: User { appState.activeUser }

    private var rows: [(Icon, String, Screen?)] {
        [(.package, "My Listings", .s9_1), (.handshake, "My Borrowing", .s2_4), (.heart, "Wishlist", .s11_4),
         (.star, "Reviews", .s3_6), (.creditCard, "Payment methods", .s5_2a), (.settings, "Settings", .s1_3), (.circleHelp, "Help", .s11_5)]
    }

    var body: some View {
        ScreenScaffold {
            HStack {
                BorroLogo()
                Spacer()
                Button {
                    showingAccountSwitcher = true
                } label: {
                    HStack(spacing: Space.x4) {
                        Avatar(photo: user.photo, size: Size.iconSmall)
                        Text("Switch User")
                            .font(.s(.s12))
                            .foregroundStyle(Color.brand)
                        IconView(icon: .chevronDown, size: Size.iconSmall)
                            .foregroundStyle(Color.brand)
                    }
                    .padding(.horizontal, Space.x8)
                    .padding(.vertical, Space.x4)
                    .background(Color.brandMist, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Space.gutter)
            .frame(minHeight: Size.appBar)
        } content: {
            ProfileHeader(user: user, name: user.fullName)
            Text(user.bio.isEmpty ? "Sharing and borrowing on Borro." : user.bio)
                .font(.r(.s14))
                .foregroundStyle(Color.inkSecondary)
            VStack(spacing: Space.x12) {
                CredibilityGauge(score: user.credibility > 0 ? user.credibility : 86, label: user.credibilityLabel.isEmpty ? "High" : user.credibilityLabel)
                Text("\(user.credibility > 0 ? user.credibility : 86)/100 · \(user.credibilityLabel.isEmpty ? "High" : user.credibilityLabel) · Keep sharing thoughtfully.")
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
        .sheet(isPresented: $showingAccountSwitcher) {
            AccountSwitcherSheet()
        }
    }
}

/// Sheet that allows testing Borro as any user.
struct AccountSwitcherSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    let accounts: [User] = [
        MockData.james,
        MockData.thomas,
        MockData.kumaran,
        MockData.matthew,
        MockData.jessica,
        MockData.mei,
    ]

    var body: some View {
        SheetContainer(title: "Switch Active User", subtitle: "Test Borro as a borrower or lender") {
            VStack(spacing: Space.x12) {
                ForEach(accounts) { account in
                    Button {
                        appState.setActiveUser(account)
                        dismiss()
                    } label: {
                        HStack(spacing: Space.x12) {
                            Avatar(photo: account.photo, size: Size.avatarMedium)
                            VStack(alignment: .leading, spacing: Space.x2) {
                                HStack {
                                    Text(account.name).font(.b(.s15)).foregroundStyle(Color.ink)
                                    if account.id == appState.activeUser.id {
                                        Text("(Active)").font(.s(.s11)).foregroundStyle(Color.brand)
                                    }
                                }
                                Text(account.id == "james" ? "Borrower · 45 reviews" : "Lender · \(account.rating.isEmpty ? "★ 5.0" : account.rating)")
                                    .font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                            }
                            Spacer()
                            if account.id == appState.activeUser.id {
                                IconView(icon: .check, size: Size.iconSmall).foregroundStyle(Color.brand)
                            }
                        }
                        .cardStyle(padding: Space.x10, shadow: false)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    PreviewHost(.s8_9)
}
