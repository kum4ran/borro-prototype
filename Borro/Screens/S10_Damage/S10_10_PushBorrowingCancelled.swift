import SwiftUI

/// Figma frame "10.10 James · Push · borrowing cancelled" (node 708:2421).
struct S10_10_PushBorrowingCancelledView: View {
    @Environment(Router.self) private var router

    var body: some View {
        PushNotificationScreen(
            date: "Sunday, 18 October",
            title: "Your borrowing was cancelled",
            message: "Thomas cancelled your steamer borrowing. Your \(Scenario.depositAmount) deposit will be returned within 1 working day.",
            meta: "3 nearby alternatives are ready for you.",
            footer: "Cancellation details in My Borrowing"
        ) { router.go(.s10_11) }
    }
}

#Preview {
    PreviewHost(.s10_10)
}
