import SwiftUI

/// The illustrated campus map from Figma ("Campus map"): two white roads, blocks, labelled pins.
struct MapCard: View {
    struct Pin: Identifiable {
        var id: String { label }
        let label: String
        let position: UnitPoint
    }

    var height: CGFloat = Size.mapHeight
    var pins: [Pin] = [Pin(label: "Blk 12", position: UnitPoint(x: 0.19, y: 0.14)),
                       Pin(label: "Blk 48", position: UnitPoint(x: 0.66, y: 0.66))]
    var showsRadius = true
    var footnote = "SINGAPORE · BENCOOLEN"

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack(alignment: .topLeading) {
                Color.mapLand
                RoundedRectangle(cornerRadius: Radius.r8).fill(Color.mapBlockLight)
                    .frame(width: w * 0.24, height: h * 0.22).offset(x: w * 0.03, y: h * 0.02)
                RoundedRectangle(cornerRadius: Radius.r8).fill(Color.mapBlock)
                    .frame(width: w * 0.26, height: h * 0.24).offset(x: w * 0.71, y: h * 0.73)
                Rectangle().fill(Color.surface.opacity(0.85))
                    .frame(width: w * 0.06, height: h * 1.3)
                    .rotationEffect(.degrees(Size.mapRoadTilt))
                    .offset(x: w * 0.30, y: -h * 0.12)
                Rectangle().fill(Color.surface.opacity(0.85))
                    .frame(width: w * 1.2, height: h * 0.07)
                    .rotationEffect(.degrees(-Size.mapRoadTilt))
                    .offset(x: -w * 0.1, y: h * 0.27)
                Text("Bras Basah Rd").font(.r(.s10)).foregroundStyle(Color.inkSecondary)
                    .offset(x: w * 0.47, y: h * 0.28)
                if showsRadius {
                    Ellipse()
                        .fill(Color.success.opacity(0.08))
                        .overlay(Ellipse().strokeBorder(Color.success, lineWidth: Size.mapRadiusStroke))
                        .frame(width: w * 0.57, height: h * 0.72)
                        .position(x: w * 0.5, y: h * 0.52)
                }
                Circle().fill(Color.brand)
                    .overlay(Circle().strokeBorder(Color.surface, lineWidth: Size.mapDotStroke))
                    .frame(width: Size.mapDot, height: Size.mapDot)
                    .position(x: w * 0.5, y: h * 0.52)
                ForEach(pins) { pin in
                    HStack(spacing: Space.x4) {
                        IconView(icon: .mapPin, size: Size.pinIcon).foregroundStyle(Color.success)
                        Text(pin.label).font(.b(.s12)).foregroundStyle(Color.inkBlack)
                    }
                    .padding(.horizontal, Space.x7)
                    .padding(.vertical, Space.x7)
                    .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.r8))
                    .offset(x: w * pin.position.x, y: h * pin.position.y)
                }
                Text(footnote).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    .offset(x: Space.x12, y: h - Space.x28)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .accessibilityElement()
        .accessibilityLabel("Map of Bencoolen with pins at Block 12 and Block 48")
    }
}
