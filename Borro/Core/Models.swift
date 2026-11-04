import Foundation

enum Role: String, Hashable {
    case james, thomas, both

    var displayName: String {
        switch self {
        case .james: return "James"
        case .thomas: return "Thomas"
        case .both: return "Both"
        }
    }
}

struct User: Identifiable, Hashable {
    let id: String
    let name: String
    let fullName: String
    let photo: Photo
    var rating: String = ""
    var reviewCount: Int = 0
    var credibility: Int = 0
    var credibilityLabel: String = ""
    var area: String = ""
    var ageAndCity: String = ""
    var bio: String = ""
}

struct Listing: Identifiable, Hashable {
    let id: String
    let title: String
    let owner: User
    let photo: Photo
    let rating: String
    let area: String
    let availableDates: String
    var availabilityLabel: String = "Available"
    var needItNow: Bool = false
    var withinOneKm: Bool = false
}

struct BorrowRequest: Hashable {
    let reference: String
    let listing: Listing
    let borrower: User
    let lender: User
    let dates: String
    let mode: String
}

struct Agreement: Hashable {
    let request: BorrowRequest
    let pickUp: String
    let returnBy: String
    let place: String
    let deposit: String
}

struct Review: Identifiable, Hashable {
    static let maxStars = 5

    let id: String
    let author: String
    let stars: Int
    let text: String
    let date: String

    var starString: String {
        String(repeating: "★", count: stars) + String(repeating: "☆", count: max(0, 5 - stars))
    }
}

struct CredibilityFactor: Identifiable, Hashable {
    var id: String { label }
    let label: String
    let score: Int
}

/// One of the three photo sets: Thomas drop-off (T), James collection (J), return (R).
enum PhotoSetID: String, CaseIterable, Hashable {
    case dropOff = "T", collection = "J", returned = "R"
}

enum PhotoSlot: String, CaseIterable, Hashable {
    case front, back, extra

    var title: String {
        switch self {
        case .front: return "Front"
        case .back: return "Back"
        case .extra: return "Extra"
        }
    }
}

struct PhotoSet: Hashable {
    var hasFront = false
    var hasBack = false
    var hasExtra = false

    /// Only the front photo is required.
    var isComplete: Bool { hasFront }
    var count: Int { [hasFront, hasBack, hasExtra].filter { $0 }.count }

    func has(_ slot: PhotoSlot) -> Bool {
        switch slot {
        case .front: return hasFront
        case .back: return hasBack
        case .extra: return hasExtra
        }
    }
}

/// Borro status (Figma collection "Borro status").
enum BorrowStatus: String, CaseIterable, Hashable {
    case pending = "Pending"
    case handoverPending = "Handover pending"
    case onLoan = "On loan"
    case returnPending = "Return pending"
    case returned = "Returned"

    enum Tone { case amber, blue, green }

    var tone: Tone {
        switch self {
        case .pending, .handoverPending, .returnPending: return .amber
        case .onLoan: return .blue
        case .returned: return .green
        }
    }
}

enum DepositState: Hashable {
    case unpaid, held, refunded
}

/// A pill in the meet-up time sheets (4.2–4.5, 4.12).
struct TimeOption: Identifiable, Hashable {
    let id: String
    let label: String     // pill text ("7:30 pm")
    let day: String       // "Sun 18 Oct"
    let time: String      // "7:30 pm"

    /// Shown on 4.7 and later: "Sun 18 Oct · 7:30 pm".
    var value: String { "\(day) · \(time)" }
}
