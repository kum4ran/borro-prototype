import Foundation

/// A day in October 2026, the only month the story uses. Weekdays are computed from
/// 1 Oct 2026 (a Thursday); the app never reads the real date.
struct OctDay: Hashable, Comparable, Identifiable {
    let day: Int

    var id: Int { day }

    static let firstWeekdayIndex = 3          // 1 Oct 2026 is a Thursday (Mon = 0)
    static let daysInMonth = 31

    private static let shortNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private static let longNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    private var weekdayIndex: Int { (Self.firstWeekdayIndex + day - 1) % 7 }

    /// "18 Oct"
    var short: String { "\(day) Oct" }
    /// "Sun 18 Oct"
    var medium: String { "\(Self.shortNames[weekdayIndex]) \(day) Oct" }
    /// "18 Oct 2026"
    var withYear: String { "\(day) Oct 2026" }
    /// "Sunday, 18 October" (lock-screen pushes)
    var lockScreen: String { "\(Self.longNames[weekdayIndex]), \(day) October" }

    static func < (a: OctDay, b: OctDay) -> Bool { a.day < b.day }
}

/// A time of day, stored as 24-hour hour and minute.
struct TimeOfDay: Hashable, Comparable, Identifiable {
    let hour: Int
    let minute: Int

    var id: Int { hour * 60 + minute }

    private var hour12: Int { hour % 12 == 0 ? 12 : hour % 12 }
    private var suffix: String { hour < 12 ? "am" : "pm" }

    /// "7:30 pm", "11:00 pm"
    var label: String { String(format: "%d:%02d %@", hour12, minute, suffix) }
    /// Pill text: "7 pm", "7:30 pm"
    var pill: String { minute == 0 ? "\(hour12) \(suffix)" : label }
    /// "7:30 PM"
    var caps: String { label.uppercased() }
    /// Wheel columns: "19", "30"
    var wheelHour: String { String(format: "%02d", hour) }
    var wheelMinute: String { String(format: "%02d", minute) }

    static func < (a: TimeOfDay, b: TimeOfDay) -> Bool { a.id < b.id }

    /// "7, 7:30 pm" when every time shares am/pm, otherwise "9 am, 7 pm".
    static func compactList(_ times: [TimeOfDay]) -> String {
        let sorted = times.sorted()
        guard let first = sorted.first else { return "No times yet" }
        if sorted.allSatisfy({ ($0.hour < 12) == (first.hour < 12) }) {
            let numbers = sorted.map { $0.minute == 0 ? "\($0.hour12)" : String(format: "%d:%02d", $0.hour12, $0.minute) }
            return numbers.joined(separator: ", ") + " " + first.suffix
        }
        return sorted.map(\.pill).joined(separator: ", ")
    }
}

/// Meet-up spots James and Thomas can pick (4.6 map, 4.13 radio).
enum MeetingSpot: String, CaseIterable, Identifiable {
    case blockA = "Block A Security Desk"
    case blk12 = "Blk 12"
    case blk48 = "Blk 48"
    case westWing = "West Wing Lobby"

    var id: String { rawValue }
    var name: String { rawValue }

    /// Spots shown on the 4.6 map.
    static let onMap: [MeetingSpot] = [.blockA, .blk12, .blk48]
    /// Spots Thomas can suggest on 4.13.
    static let lenderChoices: [MeetingSpot] = [.westWing, .blockA]

    var distanceNote: String {
        switch self {
        case .blockA: return "120 m from you · Close to both preferred spots"
        case .blk12: return "300 m from you · Closer to your place"
        case .blk48: return "450 m from you · Closer to Thomas"
        case .westWing: return "600 m from you · Thomas's preferred spot"
        }
    }
}

/// Search radius stops on 1.4.
enum RadiusStop: Int, CaseIterable, Identifiable {
    case current, m500, km1, km2, km5

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .current: return "Current"
        case .m500: return "500 m"
        case .km1: return "1 km"
        case .km2: return "2 km"
        case .km5: return "5 km"
        }
    }

    /// In metres; "Current" means the block you are standing in.
    var metres: Int {
        switch self {
        case .current: return 250
        case .m500: return 500
        case .km1: return 1_000
        case .km2: return 2_000
        case .km5: return 5_000
        }
    }

    /// "within 1 km", "around you" for Current.
    var phrase: String { self == .current ? "around you" : "within \(label)" }
}

/// How James pays the deposit on 5.2.
enum PaymentMethod: String, Hashable {
    case payNow = "PayNow"
    case applePay = "Apple Pay"
}
