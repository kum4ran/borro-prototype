import SwiftUI

/// Figma frame "8.8 Both · Timeline · deposit refunded" (node 691:6764).
/// Content follows AppState (status, deposit, drop-off), so the five timeline frames share one view.
struct S8_8_TimelineDepositRefundedView: View {
    var body: some View {
        BorrowTimeline()
    }
}

#Preview {
    PreviewHost(.s8_8) { $0.prepareForDemo(.s8_8) }
}
