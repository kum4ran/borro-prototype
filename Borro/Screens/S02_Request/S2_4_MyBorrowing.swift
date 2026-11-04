import SwiftUI

/// Figma frame "2.4 James · My Borrowing" (node 691:5063). Borro tab root.
struct S2_4_MyBorrowingView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BrandAppBar(title: "My Borrowing")
        } content: {
            SegmentHeader(tabs: ["Active", "Past Borrow"], selected: 0)
            Text("Every borrow, from first hello to safe return.")
                .font(.r(.s14)).foregroundStyle(Color.inkSecondary)
            TapArea(accessibilityLabel: "Garment Steamer, \(appState.status.rawValue)") {
                // Figma: Pending opens Thomas's push (simulated jump), any later status opens the handover.
                router.go(appState.status == .pending ? .s3_1 : .s6_1)
            } label: {
                BorrowingCard(listing: MockData.steamer, detail: appState.borrowerDetail,
                              person: MockData.thomas, personLine: "Borrowed from Thomas",
                              status: appState.status)
            }
            .accessibilityIdentifier("steamerCard")
        }
    }
}

#Preview {
    PreviewHost(.s2_4)
}
