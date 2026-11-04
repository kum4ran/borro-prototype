import SwiftUI

/// Row card on My Lending: thumbnail, title, chip, detail line, "…" menu.
struct LendingRowCard: View {
    let title: String
    let photo: Photo
    let chip: Chip
    let detail: String
    var person: Photo?
    var onMore: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: Space.x12) {
            PhotoView(photo: photo)
                .frame(width: Size.thumbSquare, height: Size.thumbHeight)
                .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
            VStack(alignment: .leading, spacing: Space.x5) {
                HStack {
                    Text(title).font(.b(.s14)).foregroundStyle(Color.ink)
                    Spacer()
                    IconButton(icon: .ellipsis, size: Size.iconSmall, label: "Manage \(title)") { onMore?() }
                        .padding(-Space.x12)
                        .accessibilityIdentifier("manage.\(title)")
                }
                if let person {
                    HStack(spacing: Space.x5) {
                        Avatar(photo: person, size: Size.avatarMini)
                        Text(detail).font(.r(.s11)).foregroundStyle(Color.ink)
                    }
                    chip
                } else {
                    chip
                    Text(detail).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .cardStyle(padding: Space.x10)
    }
}

extension MockData.LendingRow {
    var chipView: Chip {
        switch chipTone {
        case .amber: return Chip(text: chip, fill: .pendingFill, ink: .pendingInk)
        case .blue: return Chip(text: chip, fill: .brandMist, ink: .brand)
        case .green: return Chip(text: chip, fill: .successFill, ink: .success)
        case nil: return Chip(text: chip, fill: .dangerFill, ink: .danger)
        }
    }
}

/// Selectable pill in the sort/filter sheets.
struct FilterPill: View {
    let label: String
    var selected = false

    var body: some View {
        Text(label)
            .font(selected ? .s(.s13) : .r(.s13))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, Space.x12)
            .frame(minHeight: Size.filterPill)
            .background(Color.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(selected ? Color.brandDeep : Color.stroke, lineWidth: selected ? Size.buttonStroke : Size.stroke))
    }
}

/// Wrapping row of pills.
struct PillFlow: View {
    let pills: [(String, Bool)]

    var body: some View {
        FlowLayout(spacing: Space.x8) {
            ForEach(pills, id: \.0) { FilterPill(label: $0.0, selected: $0.1) }
        }
    }
}

/// Simple left-to-right wrapping layout.
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width == .infinity ? x : width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

/// Step header for List an Item: back chevron, "List an Item", step line, 8-segment progress.
struct ListingStepHeader: View {
    let step: Int
    let caption: String
    var backTo: Screen?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x8) {
            BackAppBar(title: "List an Item", subtitle: "Step \(step) of 8 · \(caption)", backTo: backTo)
            HStack(spacing: Space.x4) {
                ForEach(1...8, id: \.self) { i in
                    Capsule().fill(i <= step ? Color.brand : Color.track).frame(height: Size.listingStepBar)
                }
            }
            .padding(.horizontal, Space.gutter)
            .accessibilityHidden(true)
        }
    }
}

/// Labelled white field (List an Item forms).
struct LabeledField: View {
    let label: String
    let value: String
    var dropdown = false
    var multiline = false

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x8) {
            Text(label).font(.b(.s13)).foregroundStyle(Color.ink)
            HStack(alignment: .top) {
                Text(value).font(.r(.s15)).foregroundStyle(Color.ink)
                Spacer()
                if dropdown { IconView(icon: .chevronDown, size: Size.iconSmall).foregroundStyle(Color.ink) }
            }
            .padding(Space.x12)
            .frame(minHeight: multiline ? Size.multilineField : Size.inputHeight, alignment: .topLeading)
            .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.photo))
            .overlay(RoundedRectangle(cornerRadius: Radius.photo).strokeBorder(Color.stroke, lineWidth: Size.stroke))
        }
        .accessibilityElement(children: .combine)
    }
}
