import SwiftUI

/// Figma "Bottom navigation": Home, Borro, Lend, You. Active tab is blue.
struct AppTabBar: View {
    let active: AppTab
    @Environment(Router.self) private var router

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    router.select(tab)
                } label: {
                    VStack(spacing: Space.x3) {
                        IconView(icon: tab.icon, size: Size.tabIcon)
                        Text(tab.title)
                            .font(tab == active ? .b(.s10) : .m(.s10))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .foregroundStyle(tab == active ? Color.brand : Color.inkSecondary)
                    .frame(maxWidth: .infinity, minHeight: Size.hitTarget)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityIdentifier("tab.\(tab.rawValue)")
                .accessibilityAddTraits(tab == active ? .isSelected : [])
            }
        }
        .padding(.horizontal, Space.x16)
        .padding(.top, Space.x10)
        .padding(.bottom, Space.x4)
        .background(Color.surface.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) { Rectangle().fill(Color.stroke).frame(height: Size.stroke) }
    }
}

private extension AppTab {
    var icon: Icon {
        switch self {
        case .home: return .house
        case .borro: return .handshake
        case .lend: return .packageOpen
        case .you: return .userRound
        }
    }
}
