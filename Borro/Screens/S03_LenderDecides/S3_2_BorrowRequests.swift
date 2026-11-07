import SwiftUI

/// Figma frame "3.2 Thomas · Borrow Requests" (node 700:125).
struct S3_2_BorrowRequestsView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Borrow Requests", subtitle: "Thomas · 3 new requests")
        } content: {
            RequestCard(requester: MockData.james, dates: appState.borrowRange,
                        onOpen: { router.go(.s3_3) },
                        onAccept: { router.go(.s3_7) },
                        onReject: { router.back() })
            ForEach(MockData.otherRequests, id: \.user.id) { request in
                RequestCard(requester: request.user, dates: request.dates, urgent: request.urgent,
                            onOpen: { router.go(.s3_3) },
                            onAccept: { router.go(.s3_7) },
                            onReject: { router.back() })
            }
        }
    }
}

#Preview {
    PreviewHost(.s3_2)
}
