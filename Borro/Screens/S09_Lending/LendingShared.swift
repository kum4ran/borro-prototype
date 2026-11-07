import SwiftUI

/// My Lending page (9.1 Active, 9.3 Past loans), and the page under 9.2, 9.4–9.7.
struct MyLendingPage: View {
    let past: Bool
    var pausedBottle = false

    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BrandAppBar(title: "My Lending")
        } content: {
            PrimaryButton(title: "+ List an Item", identifier: "listAnItemButton") { router.go(.s9_8) }
            TapArea(accessibilityLabel: "Borrow Requests, 3 new") { router.go(.s3_2) } label: {
                HStack(spacing: Space.x10) {
                    IconView(icon: .inbox, size: Size.icon).foregroundStyle(Color.brand)
                    Text("Borrow Requests").font(.b(.s15)).foregroundStyle(Color.ink)
                    Spacer()
                    Chip(text: "3", font: .b(.s11))
                    IconView(icon: .chevronRight, size: Size.iconSmall).foregroundStyle(Color.ink)
                }
                .cardStyle()
            }
            .accessibilityIdentifier("borrowRequestsShortcut")
            SegmentHeader(tabs: ["Active", "Past loans", "Paused"], selected: past ? 1 : 0,
                          onSelect: { router.go($0 == 1 ? .s9_3 : .s9_1) },
                          onFilter: { router.go(past ? .s9_4 : .s9_2) })
            if past {
                HStack(spacing: Space.x8) {
                    Chip(text: "All time", fill: .brandMist, ink: .brand, font: .s(.s12))
                    ForEach(["Oct 2026", "Sep 2026", "Aug 2026"], id: \.self) {
                        Chip(text: $0, fill: .surface, ink: .inkSecondary, font: .r(.s12))
                    }
                }
                ForEach(MockData.pastLending) { row in
                    LendingRowCard(title: row.title, photo: row.photo, chip: row.chipView, detail: row.detail, person: row.person)
                }
            } else {
                TapArea(accessibilityLabel: "\(MockData.steamer.title), \(appState.status.rawValue)") {
                    switch appState.status {
                    case .pending:
                        router.go(.s3_2)
                    case .handoverPending:
                        router.go(.s6_1)
                    case .onLoan:
                        router.go(.s6_20)
                    case .returnPending:
                        router.go(.s7_2)
                    case .returned:
                        router.go(.s8_6)
                    }
                } label: {
                    LendingRowCard(title: MockData.steamer.title, photo: .steamerMain,
                                   chip: Chip(text: appState.status.rawValue, fill: appState.status.chipFill, ink: appState.status.chipInk),
                                   detail: appState.lenderDetail)
                }
                .accessibilityIdentifier("lendingSteamerCard")
                ForEach(appState.customListings) { row in
                    LendingRowCard(title: row.title, photo: row.photo,
                                   chip: Chip(text: "Active", fill: .successFill, ink: .success),
                                   detail: "Listed by you · Available now") {
                        router.go(.s9_5)
                    }
                }
                ForEach(MockData.activeLending) { row in
                    let paused = pausedBottle && row.id == "bottle"
                    LendingRowCard(title: row.title, photo: row.photo,
                                   chip: paused ? Chip(text: "Paused", fill: .track, ink: .inkSecondary) : row.chipView,
                                   detail: paused ? "Hidden from discovery" : row.detail) {
                        if row.id == "bottle" { router.go(.s9_6) } else { router.go(.s9_5) }
                    }
                }
            }
        }
    }
}

/// Sort / Filter sheet (9.2, 9.4).
struct SortFilterSheet: View {
    let status: [(String, Bool)]
    let sort: [(String, Bool)]
    let showTitle: String
    let done: Screen

    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(showsHandle: false) {
            VStack(alignment: .leading, spacing: Space.x14) {
                HStack {
                    Text("Sort / Filter").font(.b(.s20)).foregroundStyle(Color.ink)
                    Spacer()
                    LinkButton(title: "Clear all") { router.go(done) }
                }
                .padding(.top, Space.x16)
                Text("Status").font(.b(.s14)).foregroundStyle(Color.ink)
                PillFlow(pills: status)
                Text("Sort by").font(.b(.s14)).foregroundStyle(Color.ink)
                PillFlow(pills: sort)
                Spacer(minLength: 0)
                PrimaryButton(title: showTitle, identifier: "showResultsButton") { router.go(done) }
            }
        }
    }
}
