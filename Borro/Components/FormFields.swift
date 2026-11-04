import SwiftUI

/// Figma "Input": white, 10 pt radius, 1 pt border, 48 pt tall. Static placeholder text.
struct InputBox: View {
    let text: String
    var icon: Icon?
    var trailing: String?
    var isPlaceholder = true

    var body: some View {
        HStack(spacing: Space.x8) {
            if let icon {
                IconView(icon: icon, size: Size.inputIcon).foregroundStyle(Color.ink)
            }
            Text(text)
                .font(.r(.s15))
                .foregroundStyle(isPlaceholder ? Color.inkSecondary : Color.ink)
            Spacer(minLength: 0)
            if let trailing {
                Text(trailing).font(.b(.s15)).foregroundStyle(Color.inkSecondary)
            }
        }
        .padding(.horizontal, Space.x12)
        .frame(minHeight: Size.inputHeight)
        .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.photo))
        .overlay(RoundedRectangle(cornerRadius: Radius.photo).strokeBorder(Color.stroke, lineWidth: Size.stroke))
        .accessibilityElement(children: .combine)
    }
}

/// Stepped radius slider from 1.4 (Current, 500 m, 1 km, 2 km, 5 km). Tap a stop or drag the thumb.
struct RadiusSlider: View {
    let stops: [String]
    let selected: Int
    var onSelect: (Int) -> Void = { _ in }

    var body: some View {
        VStack(spacing: Space.x12) {
            GeometryReader { proxy in
                let step = proxy.size.width / CGFloat(max(stops.count - 1, 1))
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.strokeWarm).frame(height: Space.x6)
                    Capsule().fill(Color.brand).frame(width: step * CGFloat(selected), height: Space.x6)
                    ForEach(stops.indices, id: \.self) { i in
                        Circle().fill(i <= selected ? Color.brand : Color.sliderOff)
                            .frame(width: Space.x8, height: Space.x8)
                            .offset(x: step * CGFloat(i) - Space.x4)
                    }
                    Circle().fill(Color.surface)
                        .overlay(Circle().strokeBorder(Color.brand, lineWidth: Size.mapDotStroke))
                        .frame(width: Size.icon, height: Size.icon)
                        .cardShadow()
                        .offset(x: step * CGFloat(selected) - Size.icon / 2)
                }
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onEnded { value in
                    let index = Int((value.location.x / step).rounded())
                    onSelect(min(max(index, 0), stops.count - 1))
                })
            }
            .frame(height: Size.hitTarget)
            HStack {
                ForEach(stops.indices, id: \.self) { i in
                    Button { onSelect(i) } label: {
                        Text(stops[i])
                            .font(i == selected ? .b(.s9) : .m(.s9))
                            .foregroundStyle(i == selected ? Color.brand : Color.inkMuted)
                            .frame(minHeight: Size.hitTarget)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("radius.\(stops[i])")
                    if i < stops.count - 1 { Spacer(minLength: 0) }
                }
            }
            .padding(.top, -Space.x16)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Search radius")
        .accessibilityValue(stops[selected])
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onSelect(min(selected + 1, stops.count - 1))
            case .decrement: onSelect(max(selected - 1, 0))
            @unknown default: break
            }
        }
    }
}
