import SwiftUI

/// Figma frame "2.3 James · Request sent · waiting for Thomas" (node 691:5008).
struct S2_3_RequestSentWaitingForThomasView: View {
    @Environment(Router.self) private var router
    private let request = MockData.request

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Request sent", subtitle: "Borrow Now · Lender approval")
        } content: {
            ResultSeal(icon: .clock, fill: .pendingFill, tint: .pendingInk)
            VStack(spacing: Space.x8) {
                Text("Waiting for Thomas").font(.b(.s24)).foregroundStyle(Color.ink)
                Text("We’ll notify you when Thomas responds.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            RequestSummaryCard(request: request)
        } actions: {
            // Figma leaves "Chat with Thomas" unwired here.
            PrimaryButton(title: "Chat with Thomas") {}
            SecondaryButton(title: "View My Borrowing", identifier: "viewMyBorrowingButton") { router.go(.s2_4) }
        }
    }
}

#Preview {
    PreviewHost(.s2_3)
}
