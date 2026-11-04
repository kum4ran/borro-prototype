import SwiftUI

/// Damage report form (10.1 empty, 10.2 filled).
struct DamageReportPage: View {
    let filled: Bool
    @Environment(Router.self) private var router

    private let areas = ["Top", "Bottom", "Front", "Back", "Left side", "Right side", "Steam head", "Other"]
    private let kinds = ["Dent", "Scratch", "Crack", "Not working", "Missing part", "Other"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Space.x8), count: 3)

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Report Damage", subtitle: "Garment Steamer · Thomas", backTo: filled ? .s10_1 : nil)
        } content: {
            Text("Show us what happened. Clear photos help both sides reach a fair outcome.")
                .font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            LazyVGrid(columns: columns, spacing: Space.x8) {
                ForEach(MockData.damageAngles, id: \.0) { angle in
                    VStack(spacing: Space.x4) {
                        PhotoView(photo: angle.1).frame(height: Size.damageTile).clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                        Text("\(angle.0) ✓").font(.s(.s10)).foregroundStyle(Color.ink)
                    }
                }
            }
            Text("+ Add another angle").font(.b(.s12)).foregroundStyle(Color.brand)
            Text("Where is the damage?").font(.b(.s13)).foregroundStyle(Color.ink)
            chips(areas, selected: "Left side")
            Text("What kind of damage?").font(.b(.s13)).foregroundStyle(Color.ink)
            chips(kinds, selected: "Dent")
            Text("Description").font(.b(.s13)).foregroundStyle(Color.ink)
            TapArea(accessibilityLabel: "Description") { if !filled { router.go(.s10_2) } } label: {
                Text(filled ? MockData.damageDescription : "Describe what happened…")
                    .font(.r(.s14))
                    .foregroundStyle(filled ? Color.ink : Color.inkSecondary)
                    .frame(maxWidth: .infinity, minHeight: Size.multilineField - Space.x20, alignment: .topLeading)
                    .padding(Space.x12)
                    .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.photo))
                    .overlay(RoundedRectangle(cornerRadius: Radius.photo).strokeBorder(Color.stroke, lineWidth: Size.stroke))
            }
            .accessibilityIdentifier("damageDescription")
        } actions: {
            if filled {
                PrimaryButton(title: "Report to Thomas", identifier: "reportDamageButton") { router.go(.s10_3) }
            } else {
                MutedButton(title: "Report to Thomas") {}
            }
        }
    }

    private func chips(_ items: [String], selected: String) -> some View {
        FlowLayout(spacing: Space.x6) {
            ForEach(items, id: \.self) { item in
                Chip(text: item, fill: item == selected ? .successFill : .track,
                     ink: item == selected ? .success : .inkSecondary, font: .s(.s11))
            }
        }
    }
}

/// Numbered checkpoint list on the damage tracker (10.3–10.5).
struct CheckpointList: View {
    enum State { case done, current, waiting }
    let items: [(title: String, state: State)]
    var onTap: ((Int) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x14) {
            ForEach(items.indices, id: \.self) { i in
                Button { onTap?(i) } label: {
                    HStack(spacing: Space.x12) {
                        ZStack {
                            Circle().fill(fill(items[i].state))
                            if items[i].state == .done {
                                IconView(icon: .check, size: Size.iconSmall).foregroundStyle(Color.brand)
                            } else {
                                Text("\(i + 1)").font(.b(.s13)).foregroundStyle(items[i].state == .current ? Color.surface : Color.inkSecondary)
                            }
                        }
                        .frame(width: Size.checkpoint, height: Size.checkpoint)
                        VStack(alignment: .leading, spacing: Space.x2) {
                            Text(items[i].title).font(.s(.s14)).foregroundStyle(items[i].state == .waiting ? Color.inkSecondary : Color.ink)
                            Text(subtitle(items[i].state)).font(.r(.s11))
                                .foregroundStyle(items[i].state == .current ? Color.brand : Color.inkSecondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("checkpoint.\(i + 1)")
            }
        }
    }

    private func fill(_ state: State) -> Color {
        switch state {
        case .done: return .brandMist
        case .current: return .brand
        case .waiting: return .track
        }
    }

    private func subtitle(_ state: State) -> String {
        switch state {
        case .done: return "Complete"
        case .current: return "In progress · Current checkpoint"
        case .waiting: return "Not started"
        }
    }
}

/// Lender card with a Request button on the alternatives screens.
struct AlternativeCard: View {
    let user: User
    let distance: String

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x10) {
            HStack(spacing: Space.x8) {
                Avatar(photo: user.photo, size: Size.avatarSmall)
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("\(user.name) ✓").font(.b(.s14)).foregroundStyle(Color.ink)
                    Text("Credibility \(user.credibility)/100 · \(user.credibilityLabel)").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                }
                Spacer()
                Chip(text: distance, fill: .successFill, ink: .success)
            }
            HStack(spacing: Space.x12) {
                PhotoView(photo: .listPhoto5).frame(width: Size.thumbSquare, height: Size.thumbSquare)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                VStack(alignment: .leading, spacing: Space.x4) {
                    Text("Garment Steamer").font(.b(.s13)).foregroundStyle(Color.ink)
                    Text("★ 4.9 · Available 18–19 Oct").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    SecondaryButton(title: "Request") {}
                }
            }
        }
        .cardStyle()
    }
}
