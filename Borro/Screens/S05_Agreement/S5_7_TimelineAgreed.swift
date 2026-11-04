import SwiftUI

/// Figma frame "5.7 Both · Timeline · agreed" (node 739:225).
/// Content follows AppState (status, deposit, drop-off), so the five timeline frames share one view.
struct S5_7_TimelineAgreedView: View {
    var body: some View {
        BorrowTimeline()
    }
}

#Preview {
    PreviewHost(.s5_7) { $0.prepareForDemo(.s5_7) }
}
