import SwiftUI

/// Round tinted badge with an icon at the top of result screens ("Result seal", 76 pt).
struct ResultSeal: View {
    let icon: Icon
    var fill: Color = .successFill
    var tint: Color = .success

    var body: some View {
        IconView(icon: icon, size: Size.sealIcon)
            .foregroundStyle(tint)
            .frame(width: Size.seal, height: Size.seal)
            .background(fill, in: Circle())
            .frame(maxWidth: .infinity)
    }
}

/// Text tabs under a big title ("Active  Past Borrow") with the filter icon on the right.
struct SegmentHeader: View {
    let tabs: [String]
    let selected: Int
    var onSelect: (Int) -> Void = { _ in }
    var onFilter: (() -> Void)?

    var body: some View {
        HStack(spacing: Space.x18) {
            ForEach(tabs.indices, id: \.self) { i in
                Button { onSelect(i) } label: {
                    Text(tabs[i])
                        .font(.b(.s15))
                        .foregroundStyle(i == selected ? Color.brand : Color.inkSecondary)
                        .frame(minHeight: Size.hitTarget)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(i == selected ? .isSelected : [])
            }
            Spacer()
            IconButton(icon: .slidersHorizontal, size: Size.iconSmall, label: "Sort and filter") { onFilter?() }
                .padding(.trailing, -Space.x12)
        }
        .padding(.vertical, -Space.x10)
    }
}

/// Borrowing / lending row card: thumbnail, title, detail line, person, status chip.
struct BorrowingCard: View {
    let listing: Listing
    let detail: String
    let person: User
    let personLine: String
    let status: BorrowStatus
    var photo: Photo = .steamerMain

    var body: some View {
        HStack(alignment: .top, spacing: Space.x12) {
            PhotoView(photo: photo)
                .frame(width: Size.thumb, height: Size.thumbHeight)
                .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
            VStack(alignment: .leading, spacing: Space.x5) {
                HStack {
                    Text(listing.title).font(.b(.s14)).foregroundStyle(Color.ink)
                    Spacer()
                    IconView(icon: .chevronRight, size: Size.iconSmall).foregroundStyle(Color.ink)
                }
                Text(detail).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: Space.x5) {
                    Avatar(photo: person.photo, size: Size.avatarMini)
                    Text(personLine).font(.r(.s11)).foregroundStyle(Color.ink)
                }
                StatusChip(status: status)
            }
        }
        .cardStyle(padding: Space.x10)
    }
}

/// Person row: avatar, bold name, secondary line.
struct PersonRow: View {
    let user: User
    var line: String
    var nameColor: Color = .ink
    var avatarSize: CGFloat = Size.avatarMedium

    var body: some View {
        HStack(spacing: Space.x10) {
            Avatar(photo: user.photo, size: avatarSize)
            VStack(alignment: .leading, spacing: Space.x2) {
                Text("\(user.name) ✓").font(.b(.s15)).foregroundStyle(nameColor)
                Text(line).font(.r(.s11)).foregroundStyle(Color.ink)
            }
        }
    }
}
