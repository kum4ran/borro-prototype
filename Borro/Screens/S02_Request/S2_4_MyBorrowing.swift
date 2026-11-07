import SwiftUI

/// Figma frame "2.4 James · My Borrowing" (node 691:5063). Borro tab root.
struct S2_4_MyBorrowingView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0

    var body: some View {
        ScreenScaffold {
            BrandAppBar(title: "My Borrowing")
        } content: {
            SegmentHeader(tabs: ["Active", "Past Borrow"], selected: selectedTab, onSelect: { selectedTab = $0 }, onFilter: { router.go(.s9_2) })
            Text("Every borrow, from first hello to safe return.")
                .font(.r(.s14)).foregroundStyle(Color.inkSecondary)
            if appState.activeUser.id == "thomas" {
                VStack(spacing: Space.x12) {
                    IconView(icon: .handshake, size: Size.avatarLarge).foregroundStyle(Color.inkSecondary)
                    Text("No active borrowings").font(.b(.s16)).foregroundStyle(Color.ink)
                    Text("Thomas is lending items in this scenario. Manage your active listings and borrow requests in My Lending.")
                        .font(.r(.s13)).foregroundStyle(Color.inkSecondary).multilineTextAlignment(.center)
                    Text("Tap the user badge at the top right to switch to James (Borrower).")
                        .font(.s(.s12)).foregroundStyle(Color.brand).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Space.x32)
                .padding(.horizontal, Space.x16)
                .cardStyle()
            } else if selectedTab == 0 {
                TapArea(accessibilityLabel: "Garment Steamer, \(appState.status.rawValue)") {
                    switch appState.status {
                    case .pending:
                        router.go(.s3_1)
                    case .handoverPending:
                        router.go(appState.dropOffSaved ? .s6_11 : .s6_1)
                    case .onLoan:
                        router.go(.s6_20)
                    case .returnPending:
                        router.go(.s7_1)
                    case .returned:
                        router.go(.s8_8)
                    }
                } label: {
                    BorrowingCard(listing: MockData.steamer, detail: appState.borrowerDetail,
                                  person: MockData.thomas, personLine: "Borrowed from Thomas",
                                  status: appState.status)
                }
                .accessibilityIdentifier("steamerCard")
            } else {
                ForEach(MockData.pastLending) { row in
                    BorrowingCard(listing: Listing(id: row.id, title: row.title, owner: MockData.thomas, photo: row.photo, rating: "★ 5.0", area: Scenario.area, availableDates: ""),
                                  detail: row.detail,
                                  person: MockData.thomas, personLine: "Borrowed from Thomas",
                                  status: .returned,
                                  photo: row.photo)
                }
            }
        }
    }
}

#Preview {
    PreviewHost(.s2_4)
}
