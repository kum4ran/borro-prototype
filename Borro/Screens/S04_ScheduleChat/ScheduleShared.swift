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

enum ScheduleKind { case pickUp, returned }

/// Date sheet (4.2 pick-up, 4.4 return). Days outside James's borrowing range are unavailable.
struct DateSheet: View {
    let kind: ScheduleKind
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        let isPickUp = kind == .pickUp
        let day = isPickUp ? appState.pickUpDay : appState.returnDay
        SheetContainer(title: isPickUp ? "Pick-up dates" : "Return dates",
                       subtitle: isPickUp ? "Tap the day you can pick it up." : "Tap every day you can take it back (after your first pick-up).") {
            VStack(spacing: Space.x12) {
                CalendarMonth(selected: [day.day],
                              highlighted: appState.borrowDays,
                              isEnabled: { d in
                                  appState.borrowDays.contains(d) && (isPickUp || d >= appState.pickUpDay.day)
                              },
                              onTap: { d in
                                  if isPickUp { appState.choosePickUpDay(OctDay(day: d)) }
                                  else { appState.chooseReturnDay(OctDay(day: d)) }
                              },
                              footnote: nil)
                CalendarLegend()
                Spacer(minLength: 0)
                SheetFooter(summary: day.medium, clear: "Clear") {
                    if isPickUp { appState.choosePickUpDay(appState.borrowStart) }
                    else { appState.chooseReturnDay(appState.borrowEnd) }
                }
                PrimaryButton(title: "Next · set times", identifier: "nextSetTimesButton") {
                    router.go(isPickUp ? .s4_3 : .s4_5)
                }
            }
        }
    }
}

/// Time sheet (4.3 pick-up, 4.5 return): spin the wheel, add a time, tap a chip to remove it.
struct TimeSheet: View {
    let kind: ScheduleKind
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @State private var hour: Int
    @State private var minute = 0

    init(kind: ScheduleKind) {
        self.kind = kind
        // Figma's wheels open on 6:00 pm (pick-up, 4.3) and 10:00 am (return, 4.5).
        _hour = State(initialValue: kind == .pickUp ? Size.defaultPickUpWheelHour : Size.defaultReturnWheelHour)
    }

    var body: some View {
        let isPickUp = kind == .pickUp
        let day = isPickUp ? appState.pickUpDay : appState.returnDay
        let offers = isPickUp ? appState.pickUpOffers : appState.returnOffers
        let time = TimeOfDay(hour: hour, minute: minute)
        let added = offers.contains(time)
        let allowed = isPickUp || appState.canOfferReturn(time)
        SheetContainer {
            VStack(alignment: .leading, spacing: Space.x14) {
                HStack(alignment: .top, spacing: Space.x8) {
                    IconButton(icon: .chevronLeft, label: "Back") { router.go(isPickUp ? .s4_2 : .s4_4) }
                        .padding(.leading, -Space.x12)
                    VStack(alignment: .leading, spacing: Space.x4) {
                        Text(isPickUp ? "Pick-up times" : "Return times").font(.b(.s20)).foregroundStyle(Color.ink)
                        Text(isPickUp ? "Pick a day, then add the times you can do."
                                      : "After your first pick-up (\(appState.pickUpDay.medium)).")
                            .font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                    }
                }
                Chip(text: "\(day.medium) · \(offers.count)", fill: .brand, ink: .surface, font: .b(.s13))
                HStack(spacing: Space.x12) {
                    TimeWheelPicker(hour: $hour, minute: $minute)
                    VStack(spacing: Space.x8) {
                        Text(day.medium).font(.b(.s14)).foregroundStyle(Color.ink)
                        Button {
                            if isPickUp { appState.addPickUpOffer(time) } else { appState.addReturnOffer(time) }
                        } label: {
                            Text("Add \(time.label)")
                                .font(.b(.s14))
                                .foregroundStyle(Color.surface)
                                .lineLimit(1)
                                .minimumScaleFactor(Size.titleMinScale)
                                .padding(.horizontal, Space.x16)
                                .frame(minHeight: Size.buttonSmall)
                                .background(added || !allowed ? Color.brandSoft : Color.brand, in: Capsule())
                        }
                        .buttonStyle(PressStyle())
                        .disabled(added || !allowed)
                        .accessibilityIdentifier("addTimeButton")
                        if added {
                            Text("Already added.").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                        } else if !allowed {
                            Text("Pick a time after pick-up.").font(.r(.s11)).foregroundStyle(Color.danger)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                VStack(alignment: .leading, spacing: Space.x10) {
                    HStack {
                        Text("Times for \(day.medium)").font(.b(.s13)).foregroundStyle(Color.ink)
                        Spacer()
                        Text("\(offers.count) times added").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    }
                    FlowLayout(spacing: Space.x8) {
                        ForEach(offers) { offer in
                            Button {
                                if isPickUp { appState.removePickUpOffer(offer) } else { appState.removeReturnOffer(offer) }
                            } label: { RemovableChip(label: offer.label) }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Remove \(offer.label)")
                                .accessibilityIdentifier("offer.\(offer.label)")
                        }
                    }
                    Text(offers.isEmpty ? "Add at least one time." : "Tap a time to add or remove it.")
                        .font(.r(.s11)).foregroundStyle(offers.isEmpty ? Color.danger : Color.inkSecondary)
                }
                .panel(.surfaceSunk, padding: Space.x12, radius: Radius.r14)
                Spacer(minLength: 0)
                SheetFooter(summary: "\(offers.count) selected", clear: "Clear times") {
                    if isPickUp { appState.clearPickUpOffers() } else { appState.clearReturnOffers() }
                }
                PrimaryButton(title: "Done", enabled: !offers.isEmpty, identifier: "timesDoneButton") {
                    router.go(isPickUp ? .s4_4 : .s4_6)
                }
            }
        }
    }
}

/// Hour and minute wheels (5-minute steps), styled like Figma's time panel.
struct TimeWheelPicker: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(spacing: 0) {
            Picker("Hour", selection: $hour) {
                ForEach(0..<24, id: \.self) { Text(String(format: "%02d", $0)).font(.b(.s22)).tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(width: Size.wheelColumn)
            .clipped()
            .accessibilityIdentifier("wheel.hour")
            Text(":").font(.b(.s22)).foregroundStyle(Color.brand)
            Picker("Minute", selection: $minute) {
                ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { Text(String(format: "%02d", $0)).font(.b(.s22)).tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(width: Size.wheelColumn)
            .clipped()
            .accessibilityIdentifier("wheel.minute")
        }
        .frame(height: Size.wheelHeight)
        .frame(maxWidth: .infinity)
        .panel(.surfaceSunk, padding: Space.x4, radius: Radius.r14)
    }
}
