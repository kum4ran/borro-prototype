import SwiftUI

// MARK: - You tab

struct YouTabView: View {
    @EnvironmentObject private var store: BorroStore
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BSpace.lg) {
                header
                stats
                menuCard
                Button {
                    router.push(.flowMap)
                } label: {
                    HStack(spacing: BSpace.sm) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 15, weight: .medium))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Figma design index")
                                .font(BFont.captionSemibold)
                            Text("All 13 sections · 122 artboards")
                                .font(BFont.micro)
                                .foregroundStyle(BColor.brand.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(BColor.brand)
                    .padding(BSpace.md)
                    .background(BColor.brandSoft)
                    .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BSpace.screen)

                Text("Borro prototype · v2.0")
                    .font(BFont.micro)
                    .foregroundStyle(BColor.inkTertiary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, BSpace.xxxl)
        }
        .bBackground()
    }

    private var header: some View {
        HStack(spacing: BSpace.md) {
            BAvatarView(photo: store.me.photo, initials: store.me.initials, size: 66)
            VStack(alignment: .leading, spacing: 4) {
                Text(store.me.name)
                    .font(BFont.bold(20))
                    .foregroundStyle(BColor.ink)
                HStack(spacing: 6) {
                    BStars(rating: store.me.rating, reviews: store.me.reviewCount)
                    BTag(text: "Verified", icon: "checkmark.seal.fill", tint: BColor.success)
                }
            }
            Spacer()
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.top, BSpace.sm)
    }

    private var stats: some View {
        HStack(spacing: BSpace.sm) {
            stat("\(store.me.itemsBorrowed)", "Borrowed")
            stat("\(store.me.itemsLent)", "Lent")
            stat("\(store.me.credibility)", "Credibility")
        }
        .padding(.horizontal, BSpace.screen)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(BFont.bold(17)).foregroundStyle(BColor.ink)
            Text(label).font(BFont.micro).foregroundStyle(BColor.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BSpace.md)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }

    private var menuCard: some View {
        VStack(spacing: 0) {
            row(icon: BIcon.handshake, title: "My Lending", subtitle: "3 active loans") {
                router.push(.flow(.lending, screen: nil))
            }
            BDivider().padding(.leading, 50)
            row(icon: "shippingbox", title: "My Borrowing", subtitle: "1 item with you") {
                router.switchTab(.borro)
            }
            BDivider().padding(.leading, 50)
            row(icon: "heart", title: "Wishlist", subtitle: "Saved for later") {
                router.push(.flow(.other, screen: "708-3039"))
            }
            BDivider().padding(.leading, 50)
            row(icon: "star", title: "Reviews", subtitle: "\(store.me.reviewCount) received") {
                router.push(.flow(.reviews, screen: nil))
            }
            BDivider().padding(.leading, 50)
            row(icon: "exclamationmark.triangle", title: "Damage & cancellation", subtitle: "Edge cases") {
                router.push(.flow(.damage, screen: nil))
            }
            BDivider().padding(.leading, 50)
            row(icon: "chart.line.uptrend.xyaxis", title: "Credibility score", subtitle: "\(store.me.credibility)/100 · \(store.me.credibilityLabel)") {
                router.push(.person(store.me))
            }
        }
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .padding(.horizontal, BSpace.screen)
    }

    private func row(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: BSpace.md) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(BColor.brand)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(BFont.body).foregroundStyle(BColor.ink)
                    Text(subtitle).font(BFont.micro).foregroundStyle(BColor.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(BColor.inkTertiary)
            }
            .padding(.horizontal, BSpace.lg)
            .frame(height: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
