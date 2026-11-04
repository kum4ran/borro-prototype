import SwiftUI

/// Figma frame "9.4 Thomas · Past loans · Sort / Filter" (node 708:518).
struct S9_4_PastLoansSortFilterView: View {
    var body: some View {
        SortFilterSheet(status: [("Returned ✓", true), ("Cancelled ✓", true)],
                        sort: [("Most recent first", true), ("Oldest first", false), ("Name A–Z", false),
                               ("Most borrowed", false), ("Highest rated", false)],
                        showTitle: "Show results", done: .s9_3)
    }
}

#Preview {
    PreviewHost(.s9_4)
}
