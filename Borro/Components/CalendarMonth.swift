import SwiftUI

/// Month grid used by the date sheets (2.2, 4.2, 4.4, 11.2). Highlights the chosen days.
/// October 2026 starts on a Thursday.
struct CalendarMonth: View {
    var title = "October 2026"
    /// Monday-first by default; 3.3 starts the week on Sunday.
    var startsSunday = false
    var dayCount = 31
    var selected: Set<Int> = [18, 19]
    var footnote: String? = "Select start and end dates"

    private var weekdays: [String] { startsSunday ? ["S", "M", "T", "W", "T", "F", "S"] : ["M", "T", "W", "T", "F", "S", "S"] }
    private var leadingBlanks: Int { startsSunday ? 4 : 3 }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x8) {
            HStack {
                IconView(icon: .chevronLeft, size: Size.iconSmall)
                Spacer()
                Text(title).font(.b(.s16))
                Spacer()
                IconView(icon: .chevronRight, size: Size.iconSmall)
            }
            .foregroundStyle(Color.ink)
            LazyVGrid(columns: columns, spacing: Space.x4) {
                ForEach(weekdays.indices.map { "w\($0)" }, id: \.self) { key in
                    let i = Int(key.dropFirst()) ?? 0
                    Text(weekdays[i]).font(.r(.s14_3)).foregroundStyle(Color.inkSecondary)
                        .frame(height: Size.calendarCell)
                }
                ForEach((0..<leadingBlanks).map { "b\($0)" }, id: \.self) { _ in
                    Color.clear.frame(height: Size.calendarCell)
                }
                ForEach(1...dayCount, id: \.self) { day in
                    let on = selected.contains(day)
                    Text("\(day)")
                        .font(.r(.s14_3))
                        .foregroundStyle(on ? Color.surface : Color.ink)
                        .frame(maxWidth: .infinity, minHeight: Size.calendarCell)
                        .background(on ? Color.brand : Color.clear)
                        .accessibilityLabel("\(day) October\(on ? ", selected" : "")")
                }
            }
            if let footnote {
                Text(footnote).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
        }
        .cardStyle()
    }
}
