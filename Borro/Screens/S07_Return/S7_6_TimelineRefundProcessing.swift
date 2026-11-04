import SwiftUI

/// Figma frame "7.6 Both · Timeline · refund processing" (node 703:2954).
/// Content follows AppState (status, deposit, drop-off), so the five timeline frames share one view.
struct S7_6_TimelineRefundProcessingView: View {
    var body: some View {
        BorrowTimeline()
    }
}

#Preview {
    PreviewHost(.s7_6) { $0.prepareForDemo(.s7_6) }
}
