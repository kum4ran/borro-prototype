import SwiftUI

/// Figma frame "2.2 James · Borrow request · Borrow Now" (node 691:4822). Sheet over 2.1.
struct S2_2_BorrowRequestBorrowNowView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        SheetContainer(title: "Choose your borrowing dates", subtitle: "Tap the days you want to borrow it.") {
            VStack(spacing: Space.x16) {
                BorrowDatesCalendar()
                VStack(alignment: .leading, spacing: Space.x4) {
                    Text(appState.borrowSummary).font(.b(.s14)).foregroundStyle(Color.ink)
                        .accessibilityIdentifier("borrowSummary")
                    Text("Urgent · \(appState.selectedListing.owner.name) gets an instant notification and must accept.")
                        .font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                }
                .panel(.successFill)
                PrimaryButton(title: "Send Request", identifier: "sendRequestButton") {
                    appState.setStatus(.pending)
                    router.go(.s2_3)
                }
            }
        }
    }
}

/// James picks the borrowing range: first tap starts it, a later day ends it (7 days at most).
struct BorrowDatesCalendar: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        let start = appState.borrowStart.day, end = appState.borrowEnd.day
        CalendarMonth(selected: [start, end],
                      inRange: Set(start...end).subtracting([start, end]),
                      isEnabled: { appState.canBorrow(OctDay(day: $0)) },
                      onTap: { appState.selectBorrowDay(OctDay(day: $0)) },
                      footnote: start == end ? "Tap a later day to set the return date" : "Tap any day to start again · up to \(Scenario.maxBorrowDays) days")
    }
}

#Preview {
    PreviewHost(.s2_2)
}
