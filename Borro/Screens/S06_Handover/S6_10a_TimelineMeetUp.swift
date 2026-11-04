import SwiftUI

/// Figma frame "6.10a Both · Timeline · meet-up" (node 739:311).
/// Content follows AppState (status, deposit, drop-off), so the five timeline frames share one view.
struct S6_10a_TimelineMeetUpView: View {
    var body: some View {
        BorrowTimeline()
    }
}

#Preview {
    PreviewHost(.s6_10a) { $0.prepareForDemo(.s6_10a) }
}
