import SwiftUI

// MARK: - Flow-level building blocks
//
// Components that several of the 13 flows share: code entry, photo steps,
// timelines, chat bubbles, map card, push-notification mock, confirmations.

// MARK: Code entry

struct BCodeBoxes: View {
    var code: String
    var length: Int = 4
    var focused: Bool = false
    var error: Bool = false

    var body: some View {
        HStack(spacing: BSpace.sm) {
            ForEach(0..<length, id: \.self) { index in
                let chars = Array(code)
                let char = index < chars.count ? String(chars[index]) : ""
                Text(char)
                    .font(BFont.bold(24))
                    .foregroundStyle(error ? BColor.danger : BColor.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(BColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                            .stroke(
                                error ? BColor.danger :
                                    (index == code.count ? BColor.brand : BColor.stroke),
                                lineWidth: index == code.count ? 1.5 : 1
                            )
                    }
            }
        }
    }
}

// MARK: Photos

struct BPhotoTile: View {
    var photo: BPhoto?
    var caption: String?
    var height: CGFloat = 96
    var showsRemove: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack(alignment: .topTrailing) {
                if let photo {
                    BImageView(photo: photo, cornerRadius: BRadius.photo)
                        .frame(height: height)
                        .frame(maxWidth: .infinity)
                } else {
                    RoundedRectangle(cornerRadius: BRadius.photo, style: .continuous)
                        .fill(BColor.surfaceAlt)
                        .frame(height: height)
                        .overlay {
                            VStack(spacing: 4) {
                                Image(systemName: "camera")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(BColor.inkSecondary)
                                if let caption {
                                    Text(caption)
                                        .font(BFont.micro)
                                        .foregroundStyle(BColor.inkSecondary)
                                }
                            }
                        }
                }
                if showsRemove {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(BColor.ink.opacity(0.7))
                        .clipShape(Circle())
                        .padding(5)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct BPhotoLabeledTile: View {
    var photo: BPhoto?
    var label: String
    var onTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            BPhotoTile(photo: photo, caption: "Add photo", height: 84, onTap: onTap)
            HStack(spacing: 4) {
                Text(label)
                    .font(BFont.microMedium)
                    .foregroundStyle(BColor.inkSecondary)
                if photo != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(BColor.success)
                }
            }
        }
    }
}

// MARK: Timeline

struct BTimelineList: View {
    var stages: [TimelineStage]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                HStack(alignment: .top, spacing: BSpace.md) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(stage.isDone ? BColor.brand : BColor.surfaceAlt)
                                .frame(width: 22, height: 22)
                            Image(systemName: stage.isDone ? "checkmark" : stage.icon)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(stage.isDone ? .white : BColor.inkTertiary)
                        }
                        if index < stages.count - 1 {
                            Rectangle()
                                .fill(stage.isDone ? BColor.brand : BColor.stroke)
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 22)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(stage.title)
                                .font(BFont.bodySemibold)
                                .foregroundStyle(stage.isDone ? BColor.ink : BColor.inkSecondary)
                            Spacer()
                            Text(stage.dateLabel)
                                .font(BFont.micro)
                                .foregroundStyle(BColor.inkTertiary)
                        }
                        Text(stage.subtitle)
                            .font(BFont.caption)
                            .foregroundStyle(BColor.inkSecondary)
                            .padding(.bottom, 14)
                    }
                    .padding(.top, 1)
                }
                .fixedSize(horizontal: false, vertical: false)
            }
        }
    }
}

// MARK: Chat

struct BChatBubble: View {
    var message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if message.isMine { Spacer(minLength: 48) }
            VStack(alignment: message.isMine ? .trailing : .leading, spacing: 3) {
                switch message.kind {
                case .photo(let photo):
                    BImageView(photo: photo, cornerRadius: 14)
                        .frame(width: 180, height: 130)
                case .proposal(let text):
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Handover proposal")
                            .font(BFont.microSemibold)
                            .foregroundStyle(BColor.brand)
                        Text(text)
                            .font(BFont.body)
                            .foregroundStyle(BColor.ink)
                    }
                    .padding(12)
                    .background(BColor.brandSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                case .system(let text):
                    Text(text)
                        .font(BFont.micro)
                        .foregroundStyle(BColor.inkSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(BColor.chipMuted)
                        .clipShape(Capsule())
                case .text:
                    Text(message.text)
                        .font(BFont.body)
                        .foregroundStyle(message.isMine ? .white : BColor.ink)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(message.isMine ? BColor.brand : BColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                Text(message.time)
                    .font(BFont.micro)
                    .foregroundStyle(BColor.inkTertiary)
            }
            if !message.isMine { Spacer(minLength: 48) }
        }
    }
}

struct BChatComposer: View {
    @Binding var text: String
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: BSpace.sm) {
            HStack(spacing: BSpace.sm) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(BColor.inkSecondary)
                TextField("Message", text: $text)
                    .font(BFont.body)
            }
            .padding(.horizontal, BSpace.md)
            .frame(height: 44)
            .background(BColor.surface)
            .clipShape(Capsule())
            .overlay { Capsule().stroke(BColor.stroke, lineWidth: 1) }

            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(text.isEmpty ? BColor.inkTertiary : BColor.brand)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(text.isEmpty)
        }
        .padding(.horizontal, BSpace.screen)
        .padding(.vertical, BSpace.sm)
        .background(BColor.bg)
        .overlay(alignment: .top) { BDivider() }
    }
}

// MARK: Map

/// Stylised neighbourhood map (offline, matches the Figma treatment).
struct BMapCard: View {
    var label: String = "Bencoolen"
    var subtitle: String = "1 km radius"
    var height: CGFloat = 180

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BRadius.card, style: .continuous)
                .fill(Color(hex: 0xE9EEE6))
            GeometryReader { geo in
                Path { path in
                    // streets
                    for i in 0..<5 {
                        let y = geo.size.height * (0.15 + Double(i) * 0.18)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y + 12))
                    }
                    for i in 0..<4 {
                        let x = geo.size.width * (0.2 + Double(i) * 0.22)
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x - 10, y: geo.size.height))
                    }
                }
                .stroke(Color.white, lineWidth: 5)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height * 0.62))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.5))
                }
                .stroke(Color(hex: 0xD7E2D6), lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))

            // radius ring
            Circle()
                .fill(BColor.brand.opacity(0.12))
                .overlay { Circle().stroke(BColor.brand.opacity(0.35), lineWidth: 1) }
                .frame(width: 110, height: 110)
            VStack(spacing: 2) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(BColor.brand)
                Text(label)
                    .font(BFont.microSemibold)
                    .foregroundStyle(BColor.ink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
            Text(subtitle)
                .font(BFont.microMedium)
                .foregroundStyle(BColor.inkSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.white.opacity(0.9))
                .clipShape(Capsule())
                .padding(8)
        }
    }
}

// MARK: Push notification mock
//
// The five push frames in Figma are lock-screen shots. Rendered inside the
// app as a lock screen so the journey can be walked end-to-end.

struct BPushScreen: View {
    var title: String
    var message: String
    var appName: String = "Borro"
    var time: String = "10:00"
    var onOpen: (() -> Void)?

    var body: some View {
        ZStack {
            BImageView(photo: .lockScreen, cornerRadius: 0)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.18).ignoresSafeArea())

            VStack(spacing: 0) {
                Spacer().frame(height: 60)
                Text(time)
                    .font(.system(size: 76, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Saturday, 17 October")
                    .font(BFont.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 2)

                Spacer().frame(height: 60)

                Button {
                    onOpen?()
                } label: {
                    HStack(alignment: .top, spacing: BSpace.md) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(BColor.brand)
                            .frame(width: 38, height: 38)
                            .overlay {
                                Text("B")
                                    .font(BFont.bold(20))
                                    .foregroundStyle(.white)
                            }
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(appName)
                                    .font(BFont.captionSemibold)
                                    .foregroundStyle(.white.opacity(0.85))
                                Spacer()
                                Text("now")
                                    .font(BFont.micro)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            Text(title)
                                .font(BFont.semibold(13))
                                .foregroundStyle(.white)
                            Text(message)
                                .font(BFont.caption)
                                .foregroundStyle(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(BSpace.md)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BSpace.lg)

                Spacer()

                Text("Swipe up to open")
                    .font(BFont.micro)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 30)
            }
        }
        .background(BColor.ink)
    }
}

// MARK: Confirmation

struct BConfirmationPanel: View {
    var icon: String = "checkmark"
    var title: String
    var message: String
    var primaryTitle: String
    var primaryAction: () -> Void
    var secondaryTitle: String?
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: BSpace.lg) {
            Spacer().frame(height: BSpace.xl)
            BStatusBubble(systemName: icon, tint: BColor.brand, size: 66)
            VStack(spacing: 6) {
                Text(title)
                    .font(BFont.sheetTitle)
                    .foregroundStyle(BColor.ink)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(BFont.caption)
                    .foregroundStyle(BColor.inkSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack(spacing: BSpace.sm) {
                Button { primaryAction() } label: { BButtonLabel(primaryTitle) }
                    .buttonStyle(BButtonStyle())
                if let secondaryTitle, let secondaryAction {
                    Button { secondaryAction() } label: { BButtonLabel(secondaryTitle) }
                        .buttonStyle(BButtonStyle(kind: .secondary))
                }
            }
        }
        .padding(BSpace.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BColor.surface)
    }
}

// MARK: Selection rows

struct BCheckRow: View {
    var title: String
    var subtitle: String?
    var isOn: Bool

    var body: some View {
        HStack(spacing: BSpace.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(BFont.body).foregroundStyle(BColor.ink)
                if let subtitle {
                    Text(subtitle).font(BFont.caption).foregroundStyle(BColor.inkSecondary)
                }
            }
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isOn ? BColor.brand : BColor.surface)
                    .frame(width: 22, height: 22)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(isOn ? BColor.brand : BColor.stroke, lineWidth: 1)
                    .frame(width: 22, height: 22)
                if isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

struct BRadioRow: View {
    var title: String
    var subtitle: String?
    var isOn: Bool

    var body: some View {
        HStack(spacing: BSpace.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(BFont.body).foregroundStyle(BColor.ink)
                if let subtitle {
                    Text(subtitle).font(BFont.caption).foregroundStyle(BColor.inkSecondary)
                }
            }
            Spacer()
            ZStack {
                Circle().stroke(isOn ? BColor.brand : BColor.stroke, lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                if isOn {
                    Circle().fill(BColor.brand).frame(width: 11, height: 11)
                }
            }
        }
    }
}

// MARK: Stepper

struct BStepPill: View {
    var number: Int
    var state: Int   // 0 locked, 1 current, 2 done
    var label: String?

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(state == 2 ? BColor.success : (state == 1 ? BColor.brand : BColor.surfaceAlt))
                    .frame(width: 20, height: 20)
                if state == 2 {
                    Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(BFont.microBold)
                        .foregroundStyle(state == 1 ? .white : BColor.inkSecondary)
                }
            }
            if let label {
                Text(label)
                    .font(BFont.microMedium)
                    .foregroundStyle(state == 0 ? BColor.inkTertiary : BColor.ink)
            }
        }
    }
}

// MARK: Info banner

struct BInfoBanner: View {
    var icon: String = "info.circle"
    var text: String
    var tint: Color = BColor.brand

    var body: some View {
        HStack(alignment: .top, spacing: BSpace.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(tint)
            Text(text)
                .font(BFont.caption)
                .foregroundStyle(BColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BSpace.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: BRadius.card, style: .continuous))
    }
}

// MARK: Calendar strip

struct BCalendarStrip: View {
    var days: [Int]
    var busyDays: [Int] = []
    var selected: Set<Int> = []
    var onTap: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(days, id: \.self) { day in
                    let busy = busyDays.contains(day)
                    let isSelected = selected.contains(day)
                    Button {
                        onTap(day)
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(day)")
                                .font(BFont.labelBold)
                                .foregroundStyle(isSelected ? .white : (busy ? BColor.inkTertiary : BColor.ink))
                            Text(["M", "T", "W", "T", "F", "S", "S"][day % 7])
                                .font(BFont.micro)
                                .foregroundStyle(isSelected ? .white.opacity(0.8) : BColor.inkTertiary)
                        }
                        .frame(width: 38, height: 52)
                        .background(isSelected ? BColor.brand : (busy ? BColor.surfaceAlt : BColor.surface))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? .clear : BColor.stroke, lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(busy)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
