import SwiftUI

/// Vector data for one Figma icon. Drawn at any size, tinted by the foreground style.
struct IconData {
    enum Style {
        case stroke(CGFloat)
        case fill
        case knockout   // white fill behind the glyph (e.g. the ringed "more" button)
    }

    struct Part {
        let d: String
        let style: Style
    }

    let size: CGSize
    let parts: [Part]
}

/// Draws an icon from `IconData` at its Figma size (or `size`), in the current foreground style.
struct IconView: View {
    let icon: Icon
    var size: CGFloat?
    var filled = false

    var body: some View {
        let data = icon.data
        let side = size ?? max(data.size.width, data.size.height)
        Canvas { context, canvasSize in
            let scale = min(canvasSize.width / data.size.width, canvasSize.height / data.size.height)
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            for part in data.parts {
                let path = SVGPath.parse(part.d).applying(transform)
                switch part.style {
                case .stroke(let width):
                    if filled { context.fill(path, with: .foreground) }
                    context.stroke(path, with: .foreground,
                                   style: StrokeStyle(lineWidth: width * scale, lineCap: .round, lineJoin: .round))
                case .fill:
                    context.fill(path, with: .foreground)
                case .knockout:
                    context.fill(path, with: .color(.surface))
                }
            }
        }
        .frame(width: side, height: side * data.size.height / data.size.width)
        .accessibilityHidden(true)
    }
}

/// Minimal parser for the absolute path commands Figma exports (M L H V C Q Z).
enum SVGPath {
    static func parse(_ d: String) -> Path {
        var path = Path()
        var numbers: [CGFloat] = []
        var command: Character = "M"
        var current = CGPoint.zero
        var start = CGPoint.zero

        func flush() {
            var i = 0
            func next() -> CGFloat? {
                guard i < numbers.count else { return nil }
                defer { i += 1 }
                return numbers[i]
            }
            switch command {
            case "M":
                var first = true
                while let x = next(), let y = next() {
                    current = CGPoint(x: x, y: y)
                    if first { path.move(to: current); start = current; first = false }
                    else { path.addLine(to: current) }
                }
            case "L":
                while let x = next(), let y = next() {
                    current = CGPoint(x: x, y: y)
                    path.addLine(to: current)
                }
            case "H":
                while let x = next() {
                    current = CGPoint(x: x, y: current.y)
                    path.addLine(to: current)
                }
            case "V":
                while let y = next() {
                    current = CGPoint(x: current.x, y: y)
                    path.addLine(to: current)
                }
            case "C":
                while let x1 = next(), let y1 = next(), let x2 = next(), let y2 = next(), let x = next(), let y = next() {
                    current = CGPoint(x: x, y: y)
                    path.addCurve(to: current, control1: CGPoint(x: x1, y: y1), control2: CGPoint(x: x2, y: y2))
                }
            case "Q":
                while let x1 = next(), let y1 = next(), let x = next(), let y = next() {
                    current = CGPoint(x: x, y: y)
                    path.addQuadCurve(to: current, control: CGPoint(x: x1, y: y1))
                }
            case "Z":
                path.closeSubpath()
                current = start
            default:
                break
            }
            numbers.removeAll()
        }

        var token = ""
        func endToken() {
            if let value = Double(token) { numbers.append(CGFloat(value)) }
            token = ""
        }
        for ch in d {
            if "MLHVCQZmlhvcqz".contains(ch) {
                endToken()
                flush()
                command = Character(ch.uppercased())
            } else if ch == " " || ch == "," {
                endToken()
            } else if ch == "-" && !token.isEmpty && token.last != "e" {
                endToken()
                token.append(ch)
            } else {
                token.append(ch)
            }
        }
        endToken()
        flush()
        return path
    }
}
