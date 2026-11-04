import SwiftUI

/// Figma frame "4.6 James · Pick on map" (node 701:951). Sheet.
struct S4_6_PickOnMapView: View {
    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(title: "Choose a meeting point") {
            VStack(alignment: .leading, spacing: Space.x12) {
                Text("Search location").font(.b(.s13)).foregroundStyle(Color.ink)
                InputBox(text: Scenario.area, icon: .radio, isPlaceholder: false)
                MeetingPointMap()
                HStack(spacing: Space.x6) {
                    Chip(text: "Your preferred spot", fill: .pendingFill, ink: .inkOlive, font: .s(.s11))
                    Chip(text: "Lender’s spot", fill: .peachFill, ink: .inkOlive, font: .s(.s11))
                    Chip(text: "Shared area", fill: .surface, ink: .ink, font: .s(.s11))
                        .overlay(Capsule().strokeBorder(Color.ink, lineWidth: Size.stroke))
                }
                VStack(alignment: .leading, spacing: Space.x4) {
                    Text("Suggested midpoint · \(Scenario.meetUpPlace)").font(.b(.s14)).foregroundStyle(Color.ink)
                    Text("120 m from you · Close to both preferred spots").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                }
                .panel(.successFill)
                Spacer(minLength: 0)
                PrimaryButton(title: "Use this location", identifier: "useLocationButton") { router.go(.s4_7) }
            }
        }
    }
}

/// Map with the two preferred-area circles from 4.6.
struct MeetingPointMap: View {
    var body: some View {
        MapCard(height: Size.meetingMap, showsRadius: false)
            .overlay {
                GeometryReader { proxy in
                    let w = proxy.size.width, h = proxy.size.height
                    Circle().fill(Color.pendingFill.opacity(Opacity.softFill))
                        .overlay(Circle().strokeBorder(Color.amber, lineWidth: Size.stroke))
                        .frame(width: w * MapGeometry.areaSize).position(x: w * MapGeometry.borrowerArea.x, y: h * MapGeometry.borrowerArea.y)
                    Circle().fill(Color.peachFill.opacity(Opacity.peachFill))
                        .overlay(Circle().strokeBorder(Color.dangerSoft, lineWidth: Size.stroke))
                        .frame(width: w * MapGeometry.areaSize).position(x: w * MapGeometry.lenderArea.x, y: h * MapGeometry.lenderArea.y)
                }
                .allowsHitTesting(false)
            }
    }
}

#Preview {
    PreviewHost(.s4_6)
}
