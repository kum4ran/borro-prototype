import SwiftUI

/// Figma frame "9.2 Thomas · My Lending · Sort / Filter" (node 708:275).
struct S9_2_MyLendingSortFilterView: View {
    var body: some View {
        SortFilterSheet(status: [("Available ✓  1", true), ("Handover pending  1", false), ("On loan  1", false),
                                 ("Overdue  1", false), ("Paused  0", false)],
                        sort: [("Due soonest", true), ("Newest listed", false), ("Oldest listed", false),
                               ("Name A–Z", false), ("Most borrowed", false), ("Highest rated", false)],
                        showTitle: "Show 1 item", done: .s9_1)
    }
}

#Preview {
    PreviewHost(.s9_2)
}
