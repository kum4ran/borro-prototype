import SwiftUI

// MARK: - Figma section index
//
// A live index of the 13 design sections and all 122 artboards. Every row
// deep-links into the matching flow so each design can be reviewed on device.

struct FlowMapView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var expanded: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BSpace.lg) {
                BAppBar(title: "Figma design index", subtitle: "13 sections · 122 artboards")

                Text("Every artboard in the Borro file, grouped by section. Tap one to open it.")
                    .font(BFont.caption)
                    .foregroundStyle(BColor.inkSecondary)
                    .padding(.horizontal, BSpace.screen)

                VStack(spacing: BSpace.sm) {
                    ForEach(FlowCatalog.sections) { section in
                        sectionCard(section)
                    }
                }
                .padding(.horizontal, BSpace.screen)
            }
            .padding(.bottom, BSpace.xxxl)
        }
        .bBackground()
    }

    private func sectionCard(_ section: FlowSection) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeOut(duration: 0.18)) {
                    if expanded.contains(section.id) { expanded.remove(section.id) }
                    else { expanded.insert(section.id) }
                }
            } label: {
                HStack(spacing: BSpace.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(BColor.brandSoft)
                            .frame(width: 38, height: 38)
                        Text(section.number)
                            .font(BFont.bold(13))
                            .foregroundStyle(BColor.brand)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.title)
                            .font(BFont.captionSemibold)
                            .foregroundStyle(BColor.ink)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Text("\(section.frames.count) artboards")
                            .font(BFont.micro)
                            .foregroundStyle(BColor.inkSecondary)
                    }
                    Spacer()
                    Image(systemName: expanded.contains(section.id) ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(BColor.inkTertiary)
                }
                .padding(BSpace.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded.contains(section.id) {
                VStack(spacing: 0) {
                    ForEach(section.frames) { frame in
                        Button {
                            router.openFrame(slug: frame.slug)
                        } label: {
                            HStack(spacing: BSpace.sm) {
                                Text("\(frame.index)")
                                    .font(BFont.microSemibold)
                                    .foregroundStyle(BColor.inkTertiary)
                                    .frame(width: 22, alignment: .trailing)
                                Text(frame.name)
                                    .font(BFont.caption)
                                    .foregroundStyle(BColor.ink)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(BColor.inkTertiary)
                            }
                            .padding(.vertical, 9)
                            .padding(.trailing, BSpace.md)
                            .padding(.leading, BSpace.md)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if frame.slug != section.frames.last?.slug {
                            BDivider().padding(.leading, 46)
                        }
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }
}
