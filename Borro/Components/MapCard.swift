import SwiftUI

/// The illustrated campus map from Figma ("Campus map"): two white roads, blocks, labelled pins.
struct MapCard: View {
    struct Pin: Identifiable {
        var id: String { label }
        let label: String
        let position: UnitPoint
    }

    var height: CGFloat = Size.mapHeight
    var pins: [Pin] = [Pin(label: "Blk 12", position: MapGeometry.pinBlock12),
                       Pin(label: "Blk 48", position: MapGeometry.pinBlock48)]
    var showsRadius = true
    var footnote = "SINGAPORE · BENCOOLEN"

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack(alignment: .topLeading) {
                Color.mapLand
                let g = MapGeometry.self
                block(g.blockA, fill: .mapBlockLight, w: w, h: h)
                block(g.blockB, fill: .mapBlock, w: w, h: h)
                Rectangle().fill(Color.surface.opacity(Opacity.road))
                    .frame(width: w * g.streetA.width, height: h * g.streetA.height)
                    .rotationEffect(.degrees(Size.mapRoadTilt))
                    .offset(x: w * g.streetA.minX, y: h * g.streetA.minY)
                Rectangle().fill(Color.surface.opacity(Opacity.road))
                    .frame(width: w * g.streetB.width, height: h * g.streetB.height)
                    .rotationEffect(.degrees(-Size.mapRoadTilt))
                    .offset(x: w * g.streetB.minX, y: h * g.streetB.minY)
                Text("Bras Basah Rd").font(.r(.s10)).foregroundStyle(Color.inkSecondary)
                    .offset(x: w * g.roadLabel.x, y: h * g.roadLabel.y)
                if showsRadius {
                    Ellipse()
                        .fill(Color.success.opacity(Opacity.radiusFill))
                        .overlay(Ellipse().strokeBorder(Color.success, lineWidth: Size.mapRadiusStroke))
                        .frame(width: w * g.radius.width, height: h * g.radius.height)
                        .position(x: w * g.center.x, y: h * g.center.y)
                }
                Circle().fill(Color.brand)
                    .overlay(Circle().strokeBorder(Color.surface, lineWidth: Size.mapDotStroke))
                    .frame(width: Size.mapDot, height: Size.mapDot)
                    .position(x: w * g.center.x, y: h * g.center.y)
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

    private func block(_ r: CGRect, fill: Color, w: CGFloat, h: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: Radius.r8).fill(fill)
            .frame(width: w * r.width, height: h * r.height)
            .offset(x: w * r.minX, y: h * r.minY)
    }
}

/// Positions in the Figma "Campus map", as fractions of the map's width and height.
enum MapGeometry {
    static let blockA = CGRect(x: 0.03, y: 0.02, width: 0.24, height: 0.22)
    static let blockB = CGRect(x: 0.71, y: 0.73, width: 0.26, height: 0.24)
    static let streetA = CGRect(x: 0.30, y: -0.12, width: 0.06, height: 1.3)    // Bencoolen St
    static let streetB = CGRect(x: -0.1, y: 0.27, width: 1.2, height: 0.07)     // Bras Basah Rd
    static let roadLabel = UnitPoint(x: 0.47, y: 0.28)
    static let radius = CGSize(width: 0.57, height: 0.72)
    static let center = UnitPoint(x: 0.5, y: 0.52)
    static let pinBlock12 = UnitPoint(x: 0.19, y: 0.14)
    static let pinBlock48 = UnitPoint(x: 0.66, y: 0.66)
    static let areaSize: CGFloat = 0.5
    static let borrowerArea = UnitPoint(x: 0.38, y: 0.45)
    static let lenderArea = UnitPoint(x: 0.62, y: 0.55)
}
