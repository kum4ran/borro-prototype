import SwiftUI

/// Big ringed code with the shared countdown ("6767 · refreshes in 0:45").
struct CodeCircle: View {
    let code: String
    let title: String
    var onInfo: (() -> Void)?

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Space.x8) {
            Button { onInfo?() } label: {
                HStack(spacing: Space.x4) {
                    Text(title).font(.b(.s13))
                    IconView(icon: .info, size: Size.iconInfo)
                }
                .foregroundStyle(Color.ink)
                .frame(minHeight: Size.hitTarget)
            }
            .buttonStyle(.plain)
            .padding(.vertical, -Space.x10)
            .accessibilityLabel("\(title), info")
            .accessibilityIdentifier("codeInfoButton")
            VStack(spacing: Space.x2) {
                Text(code).font(.b(.s29)).foregroundStyle(Color.ink)
                    .accessibilityIdentifier("codeDigits")
                Text(appState.codeTimerLabel).font(.r(.s10)).lineSpacing(Space.x4).foregroundStyle(Color.inkSecondary)
                    .monospacedDigit()
                    .accessibilityIdentifier("codeTimer")
            }
            .frame(width: Size.codeRing, height: Size.codeRing)
            .overlay(Circle().strokeBorder(Color.brand, lineWidth: Size.codeRingStroke))
            .accessibilityElement(children: .combine)
            HStack(spacing: Space.x4) {
                Text("Refreshes every few minutes").font(.r(.s10))
                IconView(icon: .info, size: Size.iconTiny - Space.x4)
            }
            .foregroundStyle(Color.inkSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Four code boxes. Interactive when `input` is given; otherwise shows `digits`.
struct CodeBoxes: View {
    enum Style { case empty, error, verified }

    var digits: String
    var style: Style
    var input: Binding<String>?
    var onTapWhenLocked: (() -> Void)?

    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            if let input {
                TextField("", text: input)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($focused)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
                    .accessibilityIdentifier("codeField")
                    .onChange(of: input.wrappedValue) { _, new in
                        let clean = String(new.filter(\.isNumber).prefix(4))
                        if clean != new { input.wrappedValue = clean }
                    }
            }
            HStack(spacing: Space.x12) {
                ForEach(0..<4, id: \.self) { i in
                    let chars = Array(digits)
                    Text(i < chars.count ? String(chars[i]) : "")
                        .font(.inter(.semibold, .s40))
                        .foregroundStyle(style == .error ? Color.danger : Color.inkBlack)
                        .frame(width: Size.codeBox.width, height: Size.codeBox.height)
                        .background(style == .error ? Color.dangerFill : Color.surface,
                                    in: RoundedRectangle(cornerRadius: Radius.photo))
                        .overlay(RoundedRectangle(cornerRadius: Radius.photo)
                            .strokeBorder(borderColor, lineWidth: Size.buttonStroke))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if let onTapWhenLocked { onTapWhenLocked() } else { focused = true }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Code")
        .accessibilityValue(digits.isEmpty ? "empty" : digits.map(String.init).joined(separator: " "))
        .accessibilityAddTraits(input != nil ? .isButton : [])
        .accessibilityIdentifier("codeBoxes")
        .onAppear { if input != nil && onTapWhenLocked == nil { focused = true } }
    }

    private var borderColor: Color {
        switch style {
        case .empty: return .dangerSoft
        case .error: return .dangerSoft
        case .verified: return .brand
        }
    }
}

/// Dashed photo slot, or the photo with a "more" button.
struct PhotoSlotView: View {
    let photo: Photo?
    let emptyLabel: String
    var onAdd: () -> Void = {}
    var onMore: (() -> Void)?

    var body: some View {
        Group {
            if let photo {
                PhotoView(photo: photo)
                    .overlay(alignment: .topTrailing) {
                        if let onMore {
                            IconButton(icon: .moreHorizontal, size: Size.moreButton, tint: .brand, label: "Photo options", action: onMore)
                                .accessibilityIdentifier("photoOptionsButton")
                        }
                    }
            } else {
                Button(action: onAdd) {
                    HStack(spacing: Space.x6) {
                        IconView(icon: .uploadCloud, size: Size.icon)
                        Text(emptyLabel).font(.b(.s14))
                    }
                    .foregroundStyle(Color.brand)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.surface)
                    .overlay(RoundedRectangle(cornerRadius: Radius.photo)
                        .strokeBorder(Color.greyLight, style: StrokeStyle(lineWidth: Size.stroke, dash: [Space.x5, Space.x4])))
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
                .accessibilityIdentifier("addPhotoButton")
            }
        }
        .frame(height: Size.photoSlot)
        .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
    }
}

/// "< 1 2 3 >" pager under the photo slot. Filled dots have a photo; the ringed one is current.
struct PhotoPager: View {
    let current: Int
    let filled: [Bool]
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: Space.x8) {
            IconButton(icon: .chevronLeft, size: Size.iconTiny, tint: .inkSecondary, label: "Previous photo") {
                if current > 0 { onSelect(current - 1) }
            }
            .background(Color.track, in: Circle().inset(by: Space.x10))
            .accessibilityIdentifier("prevPhoto")
            ForEach(filled.indices, id: \.self) { i in
                Button { onSelect(i) } label: {
                    Text("\(i + 1)")
                        .font(.m(.s11))
                        .foregroundStyle(filled[i] ? Color.surface : (i == current ? Color.brand : Color.inkSecondary))
                        .frame(width: Size.pagerDot, height: Size.pagerDot)
                        .background(filled[i] ? Color.brand : Color.track, in: Circle())
                        .overlay(Circle().strokeBorder(i == current && !filled[i] ? Color.brand : .clear, lineWidth: Size.buttonStroke))
                        .padding(Space.x4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Photo \(i + 1)\(filled[i] ? ", added" : "")")
                .accessibilityAddTraits(i == current ? .isSelected : [])
            }
            IconButton(icon: .chevronRight, size: Size.iconTiny, tint: .inkSecondary, label: "Next photo") {
                if current < filled.count - 1 { onSelect(current + 1) }
            }
            .background(Color.track, in: Circle().inset(by: Space.x10))
            .accessibilityIdentifier("nextPhoto")
        }
        .padding(.vertical, -Space.x8)
        .frame(maxWidth: .infinity)
    }
}

/// Floating action menu over a photo (6.7, 6.16).
struct PhotoOptionsMenu: View {
    let onDelete: () -> Void
    let onUpload: () -> Void
    let onRetake: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            row(.iconTrash, "Delete Photo", tint: .danger, action: onDelete)
            row(.iconUpload, "Upload New Photo", tint: .ink, action: onUpload)
            row(.iconCamera, "Take New Photo", tint: .ink, action: onRetake)
        }
        .padding(.vertical, Space.x6)
        .frame(width: Size.photoMenu)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.r14))
        .background(Color.surface.opacity(0.7), in: RoundedRectangle(cornerRadius: Radius.r14))
        .raisedShadow()
    }

    private func row(_ icon: Icon, _ title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Space.x12) {
                IconView(icon: icon, size: Size.iconSmall)
                Text(title).font(.r(.s15))
                Spacer()
            }
            .foregroundStyle(tint)
            .padding(.horizontal, Space.x16)
            .frame(minHeight: Size.hitTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("photoMenu.\(title)")
    }
}
