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
    var distanceMetres: Int = 0
    var itemDescription: String = ""

    var resolvedDescription: String {
        if !itemDescription.isEmpty { return itemDescription }
        switch id {
        case "steamer":
            return "Freshen up your outfit in minutes. Lightweight handheld steamer, ready in 30 seconds. Includes a heat-resistant mitt."
        case "jbl":
            return "Powerful portable Bluetooth speaker with deep bass and 12-hour battery life. Waterproof and dustproof."
        case "projector":
            return "Full HD 1080p portable mini projector with built-in speaker and HDMI/USB inputs. Perfect for movie nights."
        case "screen":
            return "100-inch foldable anti-crease projection screen with stand. Quick 5-minute setup for indoor and outdoor use."
        case "camera":
            return "Compact 4K vlogging camera with flip screen, fast autofocus, and clean HDMI output."
        case "football":
            return "Official size 5 match football. High-durability composite leather, pumped and ready to play."
        case "xiaomiSteamer":
            return "Compact handheld garment steamer. Heats up in 30 seconds with constant steam pressure."
        default:
            return "Available for borrow in \(area). Well-maintained and verified before handover."
        }
    }
}

struct BorrowRequest: Hashable {
    let reference: String
    let listing: Listing
    let borrower: User
    let lender: User
    let mode: String
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
