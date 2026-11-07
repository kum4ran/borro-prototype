import SwiftUI

/// Figma "Search": pill field plus blue Search button.
struct SearchBar: View {
    var query: String?
    var placeholder = "What do you need?"
    var onSearch: () -> Void = {}

    var body: some View {
        HStack(spacing: Space.x8) {
            HStack(spacing: Space.x8) {
                IconView(icon: .search, size: Size.iconSmall).foregroundStyle(Color.ink)
                Text(query ?? placeholder)
                    .font(.r(.s14))
                    .foregroundStyle(query == nil ? Color.inkSecondary : Color.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Space.x12)
            .frame(minHeight: Size.field)
            .background(Color.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.stroke, lineWidth: Size.stroke))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(query.map { "Search: \($0)" } ?? placeholder)

            Button(action: onSearch) {
                Text("Search")
                    .font(.b(.s13))
                    .foregroundStyle(Color.surface)
                    .padding(.horizontal, Space.x16)
                    .frame(minHeight: Size.field)
                    .background(Color.brand, in: Capsule())
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel("Search")
        }
    }
}

/// Figma "Urgency toggle": grey and ○ when off, blue and ● when on.
struct NeedItNowToggle: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("⚡ Need it Now \(isOn ? "●" : "○")")
                .font(.b(.s11))
                .foregroundStyle(isOn ? Color.white : Color.inkBlack)
                .padding(.horizontal, Space.x10)
                .padding(.vertical, Space.x8)
                .background(isOn ? Color.brandRoyal : Color.toggleOff, in: Capsule())
                .frame(minHeight: Size.hitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel("Need it Now")
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityIdentifier("needItNowToggle")
    }
}

/// Toggle on the left, filter icon on the right (Figma "Discovery controls").
struct DiscoveryControls: View {
    let needItNow: Bool
    let onToggle: () -> Void
    let onFilter: (() -> Void)?

    var body: some View {
        HStack {
            NeedItNowToggle(isOn: needItNow, action: onToggle)
            Spacer()
            IconButton(icon: .slidersHorizontal, size: Size.iconSmall, label: "Filter") { onFilter?() }
                .padding(.trailing, -Space.x12)
                .accessibilityIdentifier("filterButton")
        }
        .padding(.vertical, -Space.x8)
    }
}

/// Figma "Marketplace item" card.
struct ListingCard: View {
    let listing: Listing
    /// Need it Now cards show distance instead of dates.
    var showsDistance = false
    var photo: Photo?
    var photoHeight: CGFloat = Size.listingPhoto

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x7) {
            HStack(spacing: Space.x5) {
                Avatar(photo: listing.owner.photo, size: Size.avatarTiny)
                Text("\(listing.owner.name) ✓").font(.s(.s11)).foregroundStyle(Color.inkBlack)
            }
            PhotoView(photo: photo ?? listing.photo)
                .frame(height: photoHeight)
                .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
            HStack(spacing: Space.x3) {
                Text(listing.title).font(.b(.s12)).foregroundStyle(Color.ink).lineLimit(1)
                Spacer(minLength: 0)
                HeartToggle(liked: appState.isLiked(listing)) { appState.toggleLike(listing) }
            }
            Text(listing.rating).font(.r(.s11)).foregroundStyle(Color.ink)
            Text(listing.area).font(.r(.s10)).foregroundStyle(Color.inkSecondary)
            if showsDistance {
                Text(listing.availabilityLabel).font(.b(.s10)).foregroundStyle(Color.brandRoyal)
            } else {
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("Available").font(.s(.s10)).foregroundStyle(Color.inkSecondary)
                    Text(listing.availableDates).font(.s(.s13)).foregroundStyle(Color.brand)
                }
            }
        }
        .padding(Space.x9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.card))
    }
}

/// Small heart on cards. Liked: solid brand-blue fill, no box behind it.
struct HeartToggle: View {
    let liked: Bool
    var size: CGFloat = Size.iconTiny
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            IconView(icon: .heart, size: size, filled: liked)
                .foregroundStyle(liked ? Color.brand : Color.inkSecondary)
                .frame(minWidth: Size.hitTarget, minHeight: Size.hitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(-Space.x14)
        .accessibilityLabel(liked ? "Remove from wishlist" : "Add to wishlist")
        .accessibilityAddTraits(liked ? .isSelected : [])
    }
}

struct Avatar: View {
    let photo: Photo
    var size: CGFloat = Size.avatar

    var body: some View {
        PhotoView(photo: photo)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

/// Two-column grid of listing cards, 12 pt gaps.
struct ListingGrid: View {
    let listings: [Listing]
    var showsDistance = false
    let onTap: (Listing) -> Void

    private let columns = [GridItem(.flexible(), spacing: Space.x12, alignment: .top),
                           GridItem(.flexible(), spacing: Space.x12, alignment: .top)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Space.x12) {
            ForEach(listings) { listing in
                ListingCard(listing: listing, showsDistance: showsDistance)
                    .contentShape(Rectangle())
                    .onTapGesture { onTap(listing) }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("listing.\(listing.id)")
            }
        }
    }
}
