import SwiftUI

/// Figma frame "6.20 Both · Timeline · ongoing" (node 691:6585).
/// Content follows AppState (status, deposit, drop-off), so the five timeline frames share one view.
struct S6_20_TimelineOngoingView: View {
    var body: some View {
        BorrowTimeline()
    }
}

#Preview {
    PreviewHost(.s6_20) { $0.prepareForDemo(.s6_20) }
}
