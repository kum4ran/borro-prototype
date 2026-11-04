import SwiftUI

/// Figma frame "2.2 James · Borrow request · Borrow Now" (node 691:4822). Sheet over 2.1.
struct S2_2_BorrowRequestBorrowNowView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        SheetContainer(title: "Choose your borrowing dates", subtitle: "Tap the days you want to borrow it.") {
            VStack(spacing: Space.x16) {
                CalendarMonth()
                VStack(alignment: .leading, spacing: Space.x4) {
                    Text("18 Oct → 19 Oct · 1 day").font(.b(.s14)).foregroundStyle(Color.ink)
                    Text("Urgent · Thomas gets an instant notification and must accept.")
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

#Preview {
    PreviewHost(.s2_2)
}
