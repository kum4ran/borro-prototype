import SwiftUI

/// Figma frame "2.3 James · Request sent · waiting for Thomas" (node 691:5008).
struct S2_3_RequestSentWaitingForThomasView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    private var listing: Listing { appState.selectedListing }
    private var lender: User { listing.owner }
    private var request: BorrowRequest {
        BorrowRequest(reference: Scenario.reference, listing: listing, borrower: appState.activeUser, lender: lender, mode: "Borrow Now")
    }

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Request sent", subtitle: "Borrow Now · Lender approval")
        } content: {
            ResultSeal(icon: .clock, fill: .pendingFill, tint: .pendingInk)
            VStack(spacing: Space.x8) {
                Text("Waiting for \(lender.name)").font(.b(.s24)).foregroundStyle(Color.ink)
                Text("We’ll notify you when \(lender.name) responds.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            RequestSummaryCard(request: request)
        } actions: {
            PrimaryButton(title: "Chat with \(lender.name)") { router.go(.s4_9) }
            SecondaryButton(title: "View My Borrowing", identifier: "viewMyBorrowingButton") { router.go(.s2_4) }
        }
    }
}

#Preview {
    PreviewHost(.s2_3)
}
