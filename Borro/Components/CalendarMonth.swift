import SwiftUI

/// October 2026 month grid used by the date sheets (2.2, 3.3, 4.2, 4.4, 9.11, 11.2).
/// Chosen days are solid blue, days inside a chosen range light blue, unavailable days grey.
struct CalendarMonth: View {
    var title = "October 2026"
    var selected: Set<Int> = [Scenario.defaultBorrowStart.day, Scenario.defaultBorrowEnd.day]
    /// Days between the chosen ends, tinted.
    var inRange: Set<Int> = []
    /// Background tint for days the other person is free (4.2 / 4.4 legend).
    var highlighted: Set<Int> = []
    var isEnabled: (Int) -> Bool = { _ in true }
    var onTap: ((Int) -> Void)?
    /// Monday-first by default; 3.3 starts the week on Sunday.
    var startsSunday = false
    var footnote: String? = "Select start and end dates"

    private var weekdays: [String] { startsSunday ? ["S", "M", "T", "W", "T", "F", "S"] : ["M", "T", "W", "T", "F", "S", "S"] }
    private var leadingBlanks: Int { startsSunday ? OctDay.firstWeekdayIndex + 1 : OctDay.firstWeekdayIndex }
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
                ForEach(1...OctDay.daysInMonth, id: \.self) { day in
                    dayCell(day)
                }
            }
            if let footnote {
                Text(footnote).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
        }
        .cardStyle()
    }

    @ViewBuilder
    private func dayCell(_ day: Int) -> some View {
        let on = selected.contains(day)
        let enabled = isEnabled(day)
        let label = Text("\(day)")
            .font(.r(.s14_3))
            .foregroundStyle(on ? Color.surface : (enabled ? Color.ink : Color.greySilver))
            .frame(maxWidth: .infinity, minHeight: Size.calendarCell)
            .background(background(day, on: on))
        if let onTap, enabled {
            Button { onTap(day) } label: { label.contentShape(Rectangle()) }
                .buttonStyle(.plain)
                .accessibilityLabel("\(OctDay(day: day).medium)\(on ? ", selected" : "")")
                .accessibilityAddTraits(on ? .isSelected : [])
                .accessibilityIdentifier("day.\(day)")
        } else {
            label
                .accessibilityLabel("\(OctDay(day: day).medium)\(on ? ", selected" : "")\(enabled ? "" : ", unavailable")")
        }
    }

    private func background(_ day: Int, on: Bool) -> Color {
        if on { return .brand }
        if inRange.contains(day) { return .brandMist }
        if highlighted.contains(day) { return .pendingFill }
        return .clear
    }
}
