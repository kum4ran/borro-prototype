import SwiftUI

/// "Arrange handover" header used by 4.1–4.7.
struct ArrangeHandoverBar: View {
    var backTo: Screen? = .s3_9

    var body: some View {
        BackAppBar(title: "Arrange handover", subtitle: "Thomas · Garment Steamer", backTo: backTo)
    }
}

/// Dropdown-looking row ("Select date and time").
struct SelectRow: View {
    let text: String
    var enabled = true

    var body: some View {
        HStack(spacing: Space.x10) {
            IconView(icon: .calendar, size: Size.iconSmall).foregroundStyle(Color.brand)
            Text(text).font(.m(.s14)).foregroundStyle(Color.inkTeal)
            Spacer()
            IconView(icon: .chevronDown, size: Size.iconSmall).foregroundStyle(Color.inkSecondary)
        }
        .padding(.horizontal, Space.x14)
        .frame(minHeight: Size.selectRow)
        .background(enabled ? Color.surface : Color.track, in: RoundedRectangle(cornerRadius: Radius.r14))
        .overlay(RoundedRectangle(cornerRadius: Radius.r14).strokeBorder(Color.strokeCool, lineWidth: Size.stroke))
    }
}

/// White field with a pin icon ("Block A Security Desk").
struct AddressField: View {
    let text: String
    var placeholder = false

    var body: some View {
        HStack(spacing: Space.x10) {
            IconView(icon: .mapPin, size: Size.iconSmall).foregroundStyle(Color.inkTeal)
            Text(text).font(.m(.s14)).foregroundStyle(placeholder ? Color.inkSecondary : Color.inkTeal)
            Spacer()
        }
        .padding(.horizontal, Space.x14)
        .frame(minHeight: Size.inputHeight)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.r14))
        .overlay(RoundedRectangle(cornerRadius: Radius.r14).strokeBorder(Color.strokeCool, lineWidth: Size.stroke))
        .accessibilityElement(children: .combine)
    }
}

/// Outline "Pick on map" button (electric-blue border).
struct PickOnMapButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Pick on map")
                .font(.b(.s15))
                .foregroundStyle(Color.brandElectric)
                .frame(maxWidth: .infinity, minHeight: Size.hitTarget)
                .overlay(Capsule().strokeBorder(Color.brandElectric, lineWidth: Size.mapPinStroke))
                .contentShape(Capsule())
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier("pickOnMapButton")
    }
}

/// Section label in the scheduling screens.
struct FieldLabel: View {
    let text: String
    var body: some View {
        Text(text).font(.b(.s15)).foregroundStyle(Color.inkTeal)
    }
}

/// Date sheet (4.2 pick-up, 4.4 return).
struct DateSheet: View {
    let title: String
    let subtitle: String
    let selectedDay: Int
    let summary: String
    let next: Screen
    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(title: title, subtitle: subtitle) {
            VStack(spacing: Space.x12) {
                CalendarMonth(selected: [selectedDay], footnote: nil)
                CalendarLegend()
                Spacer(minLength: 0)
                SheetFooter(summary: summary, clear: "Clear")
                PrimaryButton(title: "Next · set times", identifier: "nextSetTimesButton") { router.go(next) }
            }
        }
    }
}

/// Time sheet (4.3 pick-up, 4.5 return).
struct TimeSheet: View {
    let title: String
    let subtitle: String
    let dayChip: String
    let day: String
    let hours: [String]
    let addLabel: String
    var addEnabled = true
    let chips: [String]
    let back: Screen
    let next: Screen
    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer {
            VStack(alignment: .leading, spacing: Space.x14) {
                HStack(alignment: .top, spacing: Space.x8) {
                    IconButton(icon: .chevronLeft, label: "Back") { router.go(back) }
                        .padding(.leading, -Space.x12)
                    VStack(alignment: .leading, spacing: Space.x4) {
                        Text(title).font(.b(.s20)).foregroundStyle(Color.ink)
                        Text(subtitle).font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                    }
                }
                Chip(text: dayChip, fill: .brand, ink: .surface, font: .b(.s13))
                HStack(spacing: Space.x12) {
                    TimeWheel(hours: hours, minutes: ["50", "55", "00", "05", "10"])
                    VStack(spacing: Space.x8) {
                        Text(day).font(.b(.s14)).foregroundStyle(Color.ink)
                        Text(addLabel)
                            .font(.b(.s14))
                            .foregroundStyle(Color.surface)
                            .padding(.horizontal, Space.x16)
                            .frame(minHeight: Size.buttonSmall)
                            .background(addEnabled ? Color.brand : Color.brandSoft, in: Capsule())
                        if !addEnabled {
                            Text("Already added.").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                VStack(alignment: .leading, spacing: Space.x10) {
                    HStack {
                        Text("Times for \(day)").font(.b(.s13)).foregroundStyle(Color.ink)
                        Spacer()
                        Text("\(chips.count) times added").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    }
                    HStack(spacing: Space.x8) { ForEach(chips, id: \.self) { RemovableChip(label: $0) } }
                    Text("Tap a time to remove it.").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                }
                .panel(.surfaceSunk, padding: Space.x12, radius: Radius.r14)
                Spacer(minLength: 0)
                SheetFooter(summary: "\(chips.count) selected", clear: "Clear times")
                PrimaryButton(title: "Done", identifier: "timesDoneButton") { router.go(next) }
            }
        }
    }
}
