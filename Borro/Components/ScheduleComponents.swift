import SwiftUI

/// Selectable time pill (Figma "Time option"). Unselected: white with blue text; selected: blue with white text.
struct TimePill: View {
    let label: String
    var selected = false
    var tinted = false        // light-blue static pills on 4.7, 4.8
    var action: (() -> Void)?

    var body: some View {
        let content = Text(label)
            .font(.s(.s12))
            .foregroundStyle(selected ? Color.surface : Color.brandDeep)
            .padding(.horizontal, Space.x8)
            .padding(.vertical, Space.x4)
            .background(selected ? Color.brand : (tinted ? Color.brandSoft : Color.surface), in: Capsule())
            .overlay(Capsule().strokeBorder(tinted || selected ? Color.clear : Color.strokeCool, lineWidth: Size.stroke))
        if let action {
            Button(action: action) {
                content.frame(minHeight: Size.hitTarget).contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label)
            .accessibilityAddTraits(selected ? .isSelected : [])
        } else {
            content
        }
    }
}

/// Large pill used in the 4.12 choice sheet.
struct BigTimePill: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.m(.s16))
                .lineLimit(1)
                .fixedSize()
                .foregroundStyle(selected ? Color.surface : Color.brandDeep)
                .padding(.horizontal, Space.x12)
                .frame(minHeight: Size.bigPill)
                .background(selected ? Color.brand : Color.surface, in: Capsule())
                .overlay(Capsule().strokeBorder(selected ? Color.clear : Color.strokeCool, lineWidth: Size.stroke))
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityIdentifier("timePill.\(label)")
    }
}

/// "Pick-up · 2 times · Sun 18 Oct [7 pm] [7:30 pm]" card (Figma "Availability field").
struct AvailabilityField: View {
    let title: String
    let count: String
    let day: String
    let pills: [String]
    var footnote: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x10) {
            HStack(spacing: Space.x8) {
                IconView(icon: .calendar, size: Size.iconSmall).foregroundStyle(Color.brand)
                Text(title).font(.b(.s15)).foregroundStyle(Color.ink)
                Spacer()
                Text(count).font(.s(.s12)).foregroundStyle(Color.inkOlive)
                    .padding(.horizontal, Space.x10).padding(.vertical, Space.x3)
                    .background(Color.surfaceWarm, in: Capsule())
                IconView(icon: .chevronDown, size: Size.iconSmall).foregroundStyle(Color.ink)
            }
            Divider1(color: .strokeSoft)
            HStack(spacing: Space.x4) {
                Text(day).font(.b(.s13)).foregroundStyle(Color.ink).frame(width: Size.dayColumn, alignment: .leading)
                ForEach(pills, id: \.self) { TimePill(label: $0, tinted: true) }
                Spacer(minLength: 0)
            }
            if let footnote {
                Text(footnote).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
        }
        .padding(Space.x14)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.r18))
        .overlay(RoundedRectangle(cornerRadius: Radius.r18).strokeBorder(Color.strokeSoft, lineWidth: Size.stroke))
    }
}

/// Green banner with an icon, bold title and body ("Waiting for Thomas", "Both confirmed").
struct InfoBanner: View {
    var icon: Icon = .clock
    let title: String
    let message: String
    var fill: Color = .successFill
    var tint: Color = .successDeep

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x4) {
            HStack(spacing: Space.x6) {
                IconView(icon: icon, size: Size.iconInfo)
                Text(title).font(.b(.s14))
            }
            .foregroundStyle(tint)
            Text(message).font(.r(.s12)).foregroundStyle(Color.ink)
        }
        .panel(fill, padding: Space.x12, radius: Radius.r14)
        .accessibilityElement(children: .combine)
    }
}

/// Summary card on 4.8, 4.11, 4.14: photo, title, label/value rows.
struct HandoverSummaryCard: View {
    let rows: [(String, String)]
    var photo: Photo = .steamerMain

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x12) {
            PhotoView(photo: photo)
                .frame(height: Size.summaryPhoto)
                .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
            VStack(alignment: .leading, spacing: Space.x10) {
                Text("Garment Steamer").font(.b(.s16)).foregroundStyle(Color.ink)
                ForEach(rows, id: \.0) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(row.0).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                            .frame(width: Size.summaryLabel, alignment: .leading)
                        if row.0 == "Meet at" {
                            IconView(icon: .mapPin, size: Size.iconTiny).foregroundStyle(Color.ink)
                                .padding(.trailing, Space.x4)
                        }
                        Text(row.1).font(.s(.s13)).foregroundStyle(Color.ink)
                    }
                }
            }
            .cardStyle(shadow: false)
        }
    }
}

/// Person strip under summaries: avatar, name, rating, "View profile".
struct PersonStrip: View {
    let user: User
    var line: String
    var onProfile: (() -> Void)?

    var body: some View {
        HStack(spacing: Space.x10) {
            Avatar(photo: user.photo, size: Size.avatarMedium)
            VStack(alignment: .leading, spacing: Space.x2) {
                Text(user.name).font(.b(.s14)).foregroundStyle(Color.ink)
                Text(line).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            Spacer()
            LinkButton(title: "View profile", font: .s(.s13)) { onProfile?() }
        }
    }
}

/// Static time wheel from 4.3 / 4.5 (hour : minute, highlighted row).
struct TimeWheel: View {
    let hours: [String]
    let minutes: [String]
    var selectedRow = 2

    var body: some View {
        HStack(spacing: Space.x8) {
            column(hours)
            Text(":").font(.b(.s22)).foregroundStyle(Color.brand)
            column(minutes)
        }
        .padding(.vertical, Space.x6)
        .frame(maxWidth: .infinity)
        .background(alignment: .center) {
            RoundedRectangle(cornerRadius: Radius.r8).fill(Color.brandSoft).frame(height: Size.wheelRow)
        }
        .panel(.surfaceSunk, padding: Space.x4, radius: Radius.r14)
        .accessibilityElement()
        .accessibilityLabel("Time \(hours[selectedRow]):\(minutes[selectedRow])")
    }

    private func column(_ values: [String]) -> some View {
        VStack(spacing: Space.x2) {
            ForEach(values.indices, id: \.self) { i in
                Text(values[i])
                    .font(i == selectedRow ? .b(.s22) : .r(.s13))
                    .foregroundStyle(i == selectedRow ? Color.brand : Color.greyLight)
                    .frame(height: i == selectedRow ? Size.wheelRow : Size.wheelRowSmall)
            }
        }
        .frame(width: Size.wheelColumn)
    }
}

/// Removable chip in the time sheets ("7:00 pm ×").
struct RemovableChip: View {
    let label: String

    var body: some View {
        HStack(spacing: Space.x6) {
            Text(label).font(.s(.s13))
            Text("×").font(.b(.s13))
        }
        .foregroundStyle(Color.brandDeep)
        .padding(.horizontal, Space.x10)
        .padding(.vertical, Space.x6)
        .background(Color.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.brandDeep, lineWidth: Size.buttonStroke))
    }
}

/// Footer row in the scheduling sheets: summary on the left, "Clear" link on the right.
struct SheetFooter: View {
    let summary: String
    let clear: String

    var body: some View {
        HStack {
            Text(summary).font(.m(.s12)).foregroundStyle(Color.ink)
            Spacer()
            Text(clear).font(.s(.s12)).foregroundStyle(Color.brand)
        }
        .padding(.top, Space.x10)
        .overlay(alignment: .top) { Divider1(color: .strokeSoft).padding(.horizontal, -Space.gutter) }
    }
}

/// Legend under the scheduling calendar.
struct CalendarLegend: View {
    var body: some View {
        HStack(spacing: Space.x10) {
            legend(Color.clear, stroke: Color.ink, "Common availability")
            legend(Color.pendingFill, stroke: nil, "Borrower available")
            legend(Color.peachFill, stroke: nil, "Lender available")
        }
    }

    private func legend(_ fill: Color, stroke: Color?, _ text: String) -> some View {
        HStack(spacing: Space.x4) {
            RoundedRectangle(cornerRadius: Radius.r2).fill(fill)
                .overlay(RoundedRectangle(cornerRadius: Radius.r2).strokeBorder(stroke ?? .clear, lineWidth: Size.stroke))
                .frame(width: Space.x8, height: Space.x8)
            Text(text).font(.r(.s9)).foregroundStyle(Color.inkSecondary)
        }
    }
}
