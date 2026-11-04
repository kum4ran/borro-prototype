import SwiftUI

// MARK: - Discover (Figma section 1)
//
// Covers all five artboards as one screen with states:
//   691-4139  1.1 Home
//   691-4256  1.2 Home · Need it Now on
//   691-4365  1.3 Filter menu
//   691-4492  1.4 Location map · 1 km
//   691-4657  1.5 Results · steamer within 1 km

struct HomeView: View {
    @EnvironmentObject private var store: BorroStore
    @EnvironmentObject private var router: AppRouter

    var startScreen: String? = nil

    @State private var needNow = false
    @State private var query = ""
    @State private var showFilter = false
    @State private var showLocation = false
    @State private var showResults = false
    @State private var locationText = "Bencoolen St"
    @State private var radiusIndex = 2
    @State private var loadingFrame = false

    private let radiusOptions: [(String, Double)] = [("250 m", 0.25), ("500 m", 0.5), ("1 km", 1), ("2 km", 2), ("5 km", 5)]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                appBar
                ScrollView {
                    VStack(alignment: .leading, spacing: BSpace.md) {
                        BSearchRow(text: $query, placeholder: "What do you need?") {
                            showResults = true
                            if query.isEmpty { query = "" }
                        }
                        controls
                        if showResults {
                            resultsHeader
                            resultsList
                        } else if needNow {
                            needNowChips
                            needNowHeader
                            needNowGrid
                        } else {
                            browseHeader
                            browseGrid
                        }
                        Spacer(minLength: 8)
                    }
                    .padding(.horizontal, BSpace.screen)
                    .padding(.top, 8)
                }
                .scrollIndicators(.hidden)
            }

            if showFilter {
                filterPanel
                    .padding(.top, 172)
                    .padding(.trailing, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .clipped()
        .bBackground()
        .onAppear(perform: applyStartScreen)
        .sheet(isPresented: $showLocation) {
            locationSheet
                .presentationDetents([.height(760)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(BRadius.sheet)
        }
    }

    // MARK: App bar

    private var appBar: some View {
        HStack(alignment: .center, spacing: BSpace.md) {
            BLogoMark(width: 72)
            VStack(alignment: .leading, spacing: 2) {
                Text("Borro")
                    .font(BFont.pageTitle)
                    .foregroundStyle(BColor.ink)
                Text("Borrow more. Own less.")
                    .font(BFont.caption)
                    .foregroundStyle(BColor.inkSecondary)
            }
            Spacer()
            Button {
                router.push(.flow(.other, screen: "708-3039"))
            } label: {
                Image(systemName: "heart")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(BColor.brand)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BSpace.screen)
        .frame(height: BMetric.appBarHeight)
    }

    // MARK: Controls

    private var controls: some View {
        HStack {
            BUrgencyToggle(isOn: needNow) {
                withAnimation(.easeOut(duration: 0.18)) {
                    needNow.toggle()
                    if !needNow { showResults = false }
                }
            }
            Spacer()
            Button {
                withAnimation(.easeOut(duration: 0.18)) { showFilter.toggle() }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(BColor.ink)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 2)
    }

    private var activeChips: some View {
        ScrollView(.horizontal) { HStack(spacing: BSpace.sm) {
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill").font(.system(size: 11, weight: .bold))
                Text("Available now").font(BFont.captionSemibold)
                Image(systemName: "xmark").font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(BColor.warning)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(BColor.warningSoft)
            .clipShape(Capsule())

            BFilterChip(title: "All locations", icon: "mappin", hasChevron: true) {
                showLocation = true
            }

            Button {
                needNow = false
                showResults = false
            } label: {
                Text("Set location")
                    .font(BFont.captionSemibold)
                    .foregroundStyle(BColor.brand)
                    .underline()
                    .fixedSize()
            }
            .buttonStyle(.plain)
        } }
        .scrollIndicators(.hidden)
    }

    private var needNowChips: some View {
        ScrollView(.horizontal) { HStack(spacing: BSpace.sm) {
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill").font(.system(size: 11, weight: .bold))
                Text("Available now").font(BFont.captionSemibold)
                Image(systemName: "xmark").font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(BColor.warning)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(BColor.warningSoft)
            .clipShape(Capsule())

            BFilterChip(title: "All locations", icon: "mappin", hasChevron: true) {
                showLocation = true
            }

            Button {
                showLocation = true
            } label: {
                Text("Set location")
                    .font(BFont.captionSemibold)
                    .foregroundStyle(BColor.brand)
                    .underline()
                    .fixedSize()
            }
            .buttonStyle(.plain)
        } }
        .scrollIndicators(.hidden)
    }

    // MARK: Browse

    private var browseHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Good things, nearby")
                .font(BFont.sectionTitle)
                .foregroundStyle(BColor.ink)
            Spacer()
            Button {
                showFilter.toggle()
            } label: {
                HStack(spacing: 3) {
                    Text("Sort").font(BFont.caption)
                    Image(systemName: "arrow.up.arrow.down").font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(BColor.inkSecondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var browseGrid: some View {
        cardRows(BItems.feed)
    }

    /// Explicit 2x2 card rows — deterministic layout, matching the 353pt grid.
    private func cardRows(_ items: [Item]) -> some View {
        VStack(spacing: BMetric.gridGap) {
            ForEach(Array(stride(from: 0, to: items.count, by: 2)), id: \.self) { start in
                HStack(spacing: BMetric.gridGap) {
                    ForEach(Array(items[start..<min(start + 2, items.count)])) { item in
                        BItemCard(
                            item: item,
                            saved: store.isSaved(item),
                            onSave: { store.toggleSaved(item) },
                            onTap: { openItem(item) },
                            showsDistance: showResults == false && needNow
                        )
                    }
                    if items.count - start == 1 {
                        Color.clear.frame(width: BMetric.cardWidth, height: 251)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: Need it Now

    private var needNowHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Available right now")
                .font(BFont.sectionTitle)
                .foregroundStyle(BColor.ink)
            Spacer()
            Text("4 results · all of Singapore")
                .font(BFont.caption)
                .foregroundStyle(BColor.inkSecondary)
        }
    }

    private var needNowGrid: some View {
        cardRows(BItems.needItNow)
    }

    // MARK: Results (1.5)

    private var resultsHeader: some View {
        VStack(alignment: .leading, spacing: BSpace.sm) {
            ScrollView(.horizontal) { HStack(spacing: BSpace.sm) {
                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill").font(.system(size: 11, weight: .bold))
                    Text("Available now").font(BFont.captionSemibold)
                    Image(systemName: "xmark").font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(BColor.warning)
                .padding(.horizontal, 12)
                .frame(height: 30)
                .background(BColor.warningSoft)
                .clipShape(Capsule())
                .overlay { Capsule().stroke(BColor.warning.opacity(0.4), lineWidth: 1) }

                HStack(spacing: 5) {
                    Image(systemName: "mappin.fill").font(.system(size: 11, weight: .bold))
                    Text("Bencoolen · 1 km").font(BFont.captionSemibold)
                    Image(systemName: "xmark").font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(BColor.brand)
                .padding(.horizontal, 12)
                .frame(height: 30)
                .background(BColor.brandSoft)
                .clipShape(Capsule())
                .overlay { Capsule().stroke(BColor.brand.opacity(0.35), lineWidth: 1) }

                Button {
                    showResults = false
                    query = ""
                    needNow = false
                } label: {
                    Text("Clear all")
                        .font(BFont.captionSemibold)
                        .foregroundStyle(BColor.brand)
                        .underline()
                        .fixedSize()
                }
                .buttonStyle(.plain)
            } }
            .scrollIndicators(.hidden)

            HStack(alignment: .firstTextBaseline) {
                Text(query.isEmpty ? "Steamers near Bencoolen" : "\(query.capitalized) near Bencoolen")
                    .font(BFont.sectionTitle)
                    .foregroundStyle(BColor.ink)
                    .lineLimit(1)
                Spacer()
                Text("1 result")
                    .font(BFont.caption)
                    .foregroundStyle(BColor.inkSecondary)
            }
            .padding(.top, 4)
        }
    }

    private var resultsList: some View {
        VStack(spacing: BSpace.md) {
            Button {
                openItem(BItems.steamer)
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        BAvatarView(photo: BPeople.thomas.photo, initials: "TL", size: 22)
                        Text("Thomas").font(BFont.captionSemibold).foregroundStyle(BColor.ink)
                        Image(systemName: "checkmark").font(.system(size: 8, weight: .bold)).foregroundStyle(BColor.brand)
                    }
                    BImageView(photo: .steamer, cornerRadius: BRadius.photo)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                    HStack {
                        Text("Garment Steamer")
                            .font(BFont.bold(14))
                            .foregroundStyle(BColor.ink)
                        Spacer()
                        Image(systemName: store.isSaved(BItems.steamer) ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundStyle(store.isSaved(BItems.steamer) ? BColor.brand : BColor.inkSecondary)
                    }
                    BStars(rating: 5.0, reviews: 10)
                    Text("Bencoolen St")
                        .font(BFont.micro)
                        .foregroundStyle(BColor.inkSecondary)
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill").font(.system(size: 10, weight: .bold))
                        Text("120 m").font(BFont.captionSemibold)
                        Text("|").font(BFont.caption)
                        Text("available now").font(BFont.captionSemibold)
                    }
                    .foregroundStyle(BColor.warning)
                }
                .padding(BSpace.cardInner + 2)
                .frame(width: 353, alignment: .leading)
                .background(BColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Filter panel (1.3)

    private var filterPanel: some View {
        VStack(spacing: 0) {
            filterRow("Location", "Within 1 km") {
                showFilter = false
                showLocation = true
            }
            BDivider()
            filterRow("Rating", "4 stars & up", action: nil)
            BDivider()
            filterRow("Reviews", "Most reviewed", action: nil)
            BDivider()
            filterRow("Availability", "18–19 Oct", action: nil)
        }
        .padding(.horizontal, BSpace.lg)
        .frame(width: 245)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .stroke(BColor.stroke, lineWidth: 1)
        }
        .bShadow(2)
    }

    private func filterRow(_ title: String, _ value: String, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(BFont.bold(15))
                        .foregroundStyle(BColor.ink)
                    Text(value)
                        .font(BFont.caption)
                        .foregroundStyle(BColor.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(BColor.ink)
            }
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }

    // MARK: Location sheet (1.4)

    private var locationSheet: some View {
        VStack(alignment: .leading, spacing: BSpace.md) {
            BSheetHandle()
            HStack(alignment: .top) {
                Text("Find it close to you")
                    .font(BFont.bold(26))
                    .foregroundStyle(BColor.ink)
                Spacer()
                Button {
                    showLocation = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(BColor.ink)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, BSpace.sm)

            Text("Location")
                .font(BFont.semibold(13))
                .foregroundStyle(BColor.ink)

            BField(placeholder: "Search location...", text: $locationText, icon: "magnifyingglass")

            locationMap
                .frame(height: 250)

            Text("Search radius")
                .font(BFont.semibold(13))
                .foregroundStyle(BColor.ink)

            radiusSlider

            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .semibold))
                Text("Searching within \(radiusOptions[radiusIndex].0) of \(locationText)")
                    .font(BFont.caption)
            }
            .foregroundStyle(BColor.inkSecondary)

            Spacer(minLength: 0)

            Button {
                store.location = locationText
                store.radiusKm = radiusOptions[radiusIndex].1
                showLocation = false
                showResults = false
            } label: {
                BButtonLabel("Search")
            }
            .buttonStyle(BButtonStyle())

            Button {
                showLocation = false
            } label: {
                BButtonLabel("Cancel")
            }
            .buttonStyle(BButtonStyle(kind: .secondary, height: 42))
            .overlay { Capsule().stroke(BColor.brand.opacity(0.5), lineWidth: 1) }
            .padding(.bottom, 6)
        }
        .padding(.horizontal, BSpace.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BColor.surface)
    }

    private var locationMap: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .fill(Color(hex: 0xE7EDE3))
            GeometryReader { geo in
                Path { p in
                    for i in 0..<4 {
                        let y = geo.size.height * (0.2 + Double(i) * 0.24)
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: geo.size.width, y: y + 18))
                    }
                    for i in 0..<3 {
                        let x = geo.size.width * (0.28 + Double(i) * 0.3)
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x - 14, y: geo.size.height))
                    }
                }
                .stroke(Color.white, lineWidth: 7)
            }
            .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))

            Circle()
                .fill(BColor.success.opacity(0.10))
                .overlay { Circle().stroke(BColor.success, lineWidth: 2) }
                .frame(width: 200, height: 200)
            Circle().fill(BColor.brand).frame(width: 10, height: 10)

            VStack {
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill").foregroundStyle(BColor.success)
                        Text("Blk 12").font(BFont.captionSemibold).foregroundStyle(BColor.ink)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill").foregroundStyle(BColor.success)
                        Text("Blk 48").font(BFont.captionSemibold).foregroundStyle(BColor.ink)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                HStack {
                    Text("SINGAPORE · BENCOOLEN")
                        .font(BFont.micro)
                        .tracking(0.8)
                        .foregroundStyle(BColor.inkSecondary)
                    Spacer()
                }
            }
            .padding(BSpace.md)
        }
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }

    private var radiusSlider: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(BColor.surfaceAlt)
                        .frame(height: 4)
                    Capsule()
                        .fill(BColor.brand)
                        .frame(width: width * CGFloat(radiusIndex) / 4 + 6, height: 4)
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(i <= radiusIndex ? BColor.brand : BColor.stroke)
                            .frame(width: i == radiusIndex ? 22 : 8, height: i == radiusIndex ? 22 : 8)
                            .overlay {
                                if i == radiusIndex {
                                    Circle().stroke(.white, lineWidth: 3)
                                }
                            }
                            .position(x: width * CGFloat(i) / 4, y: 11)
                    }
                }
                .frame(height: 22)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let step = round((value.location.x / width) * 4)
                            radiusIndex = min(4, max(0, Int(step)))
                        }
                )
            }
            .frame(height: 22)

            HStack {
                ForEach(Array(radiusOptions.enumerated()), id: \.offset) { index, option in
                    Text(option.0)
                        .font(BFont.micro)
                        .foregroundStyle(index == radiusIndex ? BColor.brand : BColor.inkSecondary)
                        .font(index == radiusIndex ? BFont.microSemibold : BFont.micro)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: Navigation / start state

    private func openItem(_ item: Item) {
        store.activeItem = item
        router.push(.flow(.request, screen: "691-4767"))
    }

    private func applyStartScreen() {
        guard let startScreen else { return }
        switch startScreen {
        case "691-4256":
            needNow = true
        case "691-4365":
            showFilter = true
        case "691-4492":
            showLocation = true
        case "691-4657":
            needNow = true
            showResults = true
            query = "Garment steamer"
        default:
            break
        }
    }
}
