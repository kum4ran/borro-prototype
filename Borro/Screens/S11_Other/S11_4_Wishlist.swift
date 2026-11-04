import SwiftUI

/// Figma frame "11.4 James · Wishlist" (node 708:3039).
struct S11_4_WishlistView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    private let columns = [GridItem(.flexible(), spacing: Space.x12, alignment: .top),
                           GridItem(.flexible(), spacing: Space.x12, alignment: .top)]

    var body: some View {
        ScreenScaffold {
            BigBackAppBar(title: "Wishlist")
        } content: {
            Text("A little collection of things you love.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            LazyVGrid(columns: columns, spacing: Space.x12) {
                ForEach(appState.wishlist) { listing in
                    WishCard(listing: listing, wished: appState.isWished(listing)) { appState.toggleWish(listing) }
                        .contentShape(Rectangle())
                        .onTapGesture { router.openListing(listing) }
                        .accessibilityIdentifier("wish.\(listing.id)")
                }
            }
        }
    }
}

/// Wishlist card: liked items show a solid brand-blue heart with no box behind it.
private struct WishCard: View {
    let listing: Listing
    let wished: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x7) {
            HStack(spacing: Space.x5) {
                Avatar(photo: listing.owner.photo, size: Size.avatarTiny)
                Text("\(listing.owner.name) ✓").font(.s(.s11)).foregroundStyle(Color.inkBlack)
            }
            PhotoView(photo: listing.photo)
                .frame(height: Size.listingPhoto)
                .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
            HStack {
                Text(listing.title).font(.b(.s12)).foregroundStyle(Color.ink).lineLimit(1)
                Spacer(minLength: 0)
                HeartToggle(liked: wished, action: toggle)
            }
            Text(listing.rating).font(.r(.s11)).foregroundStyle(Color.ink)
            Text(listing.area).font(.r(.s10)).foregroundStyle(Color.inkSecondary)
        }
        .padding(Space.x9)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.card))
    }
}

#Preview {
    PreviewHost(.s11_4)
}
