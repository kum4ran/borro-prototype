import SwiftUI

// MARK: - Flow identity

enum FlowID: String, CaseIterable, Hashable {
    case request, lender, schedule, agreement, handover, returnFlow, reviews, lending, damage, other

    var title: String {
        switch self {
        case .request: return "Request"
        case .lender: return "Lender decides"
        case .schedule: return "Schedule & chat"
        case .agreement: return "Lending agreement"
        case .handover: return "Handover"
        case .returnFlow: return "Return"
        case .reviews: return "Reviews & refund"
        case .lending: return "My Lending"
        case .damage: return "Damage & cancellation"
        case .other: return "Other screens"
        }
    }

    /// Section number(s) in the Figma file.
    var sections: [String] {
        switch self {
        case .request: return ["2"]
        case .lender: return ["3"]
        case .schedule: return ["4"]
        case .agreement: return ["5"]
        case .handover: return ["6", "6b", "6c"]
        case .returnFlow: return ["7"]
        case .reviews: return ["8"]
        case .lending: return ["9"]
        case .damage: return ["10"]
        case .other: return ["11"]
        }
    }
}

// MARK: - Routes

enum BRoute: Hashable {
    case home(screen: String?)
    case flow(FlowID, screen: String?)
    case person(Person)
    case flowMap
}

// MARK: - Router

final class AppRouter: ObservableObject {
    @Published var tab: AppTab = .home
    @Published var path: [BRoute] = []

    init() {
        // Deep links used by the screenshot/QA harness:
        //   -uiScreen 691-4139     opens that artboard
        //   -uiFlow request        opens a flow root
        //   -uiFlowMap             opens the section index
        let args = ProcessInfo.processInfo.arguments
        func value(after flag: String) -> String? {
            guard let i = args.firstIndex(of: flag), i + 1 < args.count else { return nil }
            return args[i + 1]
        }
        if let tabRaw = value(after: "-uiTab") {
            switch tabRaw.lowercased() {
            case "borro": tab = .borro
            case "lend": tab = .lend
            case "you": tab = .you
            default: tab = .home
            }
        }
        if args.contains("-uiFlowMap") {
            path = [.flowMap]
        } else if let screen = value(after: "-uiScreen") {
            let section = FlowCatalog.section(for: screen)
            if let flow = section?.flow {
                path = [.flow(flow, screen: screen)]
            } else if section != nil {
                path = [.home(screen: screen)]
            }
        } else if let flowRaw = value(after: "-uiFlow"), let flow = FlowID(rawValue: flowRaw) {
            path = [.flow(flow, screen: nil)]
        }
    }

    func push(_ route: BRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func switchTab(_ tab: AppTab) {
        self.tab = tab
        path.removeAll()
    }

    func openFrame(slug: String) {
        if let section = FlowCatalog.section(for: slug) {
            if let flow = section.flow {
                push(.flow(flow, screen: slug))
            } else {
                push(.home(screen: slug))
            }
        }
    }
}

// MARK: - Shell

struct AppShell: View {
    @StateObject private var router = AppRouter()
    @EnvironmentObject private var store: BorroStore

    var body: some View {
        NavigationStack(path: $router.path) {
            tabRoot
                .toolbar(.hidden, for: .navigationBar)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if router.path.isEmpty {
                        BTabBar(selection: Binding(
                            get: { router.tab },
                            set: { router.switchTab($0) }
                        ))
                        .background(BColor.surface)
                    }
                }
                .navigationDestination(for: BRoute.self) { route in
                    destination(route)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
        .environmentObject(router)
        .tint(BColor.brand)
    }

    @ViewBuilder
    private var tabRoot: some View {
        switch router.tab {
        case .home:
            HomeView()
        case .borro:
            MyBorrowingTabView()
        case .lend:
            LendingTabView()
        case .you:
            YouTabView()
        }
    }

    @ViewBuilder
    private func destination(_ route: BRoute) -> some View {
        switch route {
        case .home(let screen):
            HomeView(startScreen: screen)
        case .flow(let flow, let screen):
            FlowHost(flow: flow, screen: screen)
        case .person(let person):
            BPublicProfileView(person: person)
        case .flowMap:
            FlowMapView()
        }
    }
}

// MARK: - Flow host
//
// Single switch that maps a FlowID to the file owned by that flow.
// Each flow view takes an optional Figma frame slug so QA can deep-link
// straight to an artboard.

struct FlowHost: View {
    @EnvironmentObject private var router: AppRouter
    let flow: FlowID
    let screen: String?

    var body: some View {
        switch flow {
        case .request: RequestFlow(startScreen: screen)
        case .lender: LenderDecisionFlow(startScreen: screen)
        case .schedule: ScheduleChatFlow(startScreen: screen)
        case .agreement: AgreementFlow(startScreen: screen)
        case .handover: HandoverFlow(startScreen: screen)
        case .returnFlow: ReturnFlow(startScreen: screen)
        case .reviews: ReviewsFlow(startScreen: screen)
        case .lending: LendingFlow(startScreen: screen)
        case .damage: DamageFlow(startScreen: screen)
        case .other: OtherScreensFlow(startScreen: screen)
        }
    }
}

// MARK: - Shared public profile (used from many flows)

struct BPublicProfileView: View {
    var person: Person
    @Environment(\.dismiss) private var dismiss

    private var reviews: [Review] {
        [
            Review(id: "r1", author: BPeople.jessica, rating: 5,
                   text: "Everything exactly as described. Very easy handover.",
                   dateLabel: "Sep 2026", itemTitle: "Garment Steamer"),
            Review(id: "r2", author: BPeople.matthew, rating: 5,
                   text: "Responsive and careful with the item. Would lend again.",
                   dateLabel: "Aug 2026", itemTitle: "Portable Projector")
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: BSpace.lg) {
                BAppBar(title: "Profile", subtitle: "@\(person.handle.replacingOccurrences(of: "@", with: ""))")

                VStack(spacing: BSpace.sm) {
                    BAvatarView(photo: person.photo, initials: person.initials, size: 84)
                    Text(person.name)
                        .font(BFont.bold(22))
                        .foregroundStyle(BColor.ink)
                    HStack(spacing: 8) {
                        BStars(rating: person.rating, reviews: person.reviewCount)
                        BTag(text: "Verified", icon: "checkmark.seal.fill", tint: BColor.success)
                    }
                    Text(person.bio)
                        .font(BFont.caption)
                        .foregroundStyle(BColor.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BSpace.xl)
                }

                HStack(spacing: BSpace.sm) {
                    profileStat("\(person.reviewCount)", "Reviews")
                    profileStat("\(person.itemsLent)", "Lent")
                    profileStat("\(person.credibility)", "Credibility")
                }
                .padding(.horizontal, BSpace.screen)

                VStack(alignment: .leading, spacing: BSpace.sm) {
                    BSectionHeader(title: "Reviews")
                    ForEach(reviews) { review in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                BAvatarView(photo: review.author.photo, initials: review.author.initials, size: 28)
                                Text(review.author.name)
                                    .font(BFont.captionSemibold)
                                    .foregroundStyle(BColor.ink)
                                Spacer()
                                Text(review.dateLabel)
                                    .font(BFont.micro)
                                    .foregroundStyle(BColor.inkTertiary)
                            }
                            HStack(spacing: 2) {
                                ForEach(0..<5, id: \.self) { i in
                                    Image(systemName: i < review.rating ? "star.fill" : "star")
                                        .font(.system(size: 10))
                                        .foregroundStyle(BColor.ink)
                                }
                            }
                            Text(review.text)
                                .font(BFont.caption)
                                .foregroundStyle(BColor.inkSecondary)
                        }
                        .padding(BSpace.md)
                        .background(BColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                    }
                }
                .padding(.horizontal, BSpace.screen)
            }
            .padding(.bottom, BSpace.xxxl)
        }
        .bBackground()
    }

    private func profileStat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(BFont.bold(16)).foregroundStyle(BColor.ink)
            Text(label).font(BFont.micro).foregroundStyle(BColor.inkSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BSpace.md)
        .background(BColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }
}
