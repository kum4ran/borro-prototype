import Foundation

// MARK: - People

struct Person: Identifiable, Hashable {
    let id: String
    var name: String
    var handle: String
    var photo: BPhoto?
    var rating: Double
    var reviewCount: Int
    var credibility: Int
    var verified: Bool = true
    var location: String = "Bencoolen St"
    var memberSince: String = "2024"
    var bio: String = ""
    var itemsLent: Int = 0
    var itemsBorrowed: Int = 0

    var initials: String {
        name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    var credibilityLabel: String {
        switch credibility {
        case 80...: return "High"
        case 60..<80: return "Good"
        default: return "Building"
        }
    }

    var firstName: String { String(name.split(separator: " ").first ?? "Someone") }
}

// MARK: - Items

struct Item: Identifiable, Hashable {
    let id: String
    var title: String
    var subtitle: String
    var owner: Person
    var photo: BPhoto
    var photos: [BPhoto] = []
    var location: String
    var rating: Double
    var reviewCount: Int
    var distance: String
    var availability: String
    var pricePerDay: Double
    var deposit: Double
    var description: String
    var condition: String
    var category: String
    var busyDays: [Int] = []
    var pickupNote: String = "Burlington Square, concierge"

    var photoCount: Int { max(1, photos.isEmpty ? 1 : photos.count) }
    var allPhotos: [BPhoto] { photos.isEmpty ? [photo] : photos }
}

// MARK: - Requests and bookings

enum RequestStatus: String, Hashable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    case scheduled = "Scheduled"
    case agreement = "Agreement"
    case handover = "Handover"
    case borrowed = "Borrowed"
    case returned = "Returned"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

enum BorrowMode: String, Hashable {
    case now = "Borrow Now"
    case later = "Borrow Later"
}

struct DateRange: Hashable {
    var start: Date
    var end: Date

    var days: Int {
        max(1, Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1)
    }

    var label: String { BDate.range(start, end) }
}

struct BorrowRequest: Identifiable, Hashable {
    let id: String
    var item: Item
    var borrower: Person
    var lender: Person
    var status: RequestStatus
    var mode: BorrowMode
    var dates: DateRange
    var returnDates: DateRange
    var handoverCode: String
    var borrowerCode: String
    var note: String = ""
    var total: Double
    var createdAtLabel: String = "Just now"
}

// MARK: - Chat

struct ChatMessage: Identifiable, Hashable {
    let id: String
    var text: String
    var isMine: Bool
    var time: String
    var kind: ChatKind = .text

    enum ChatKind: Hashable {
        case text
        case photo(BPhoto)
        case proposal(String)
        case system(String)
    }
}

// MARK: - Timeline

struct TimelineStage: Identifiable, Hashable {
    let id: String
    var title: String
    var subtitle: String
    var dateLabel: String
    var isDone: Bool
    var isCurrent: Bool = false
    var icon: String = "checkmark"
}

struct Review: Identifiable, Hashable {
    let id: String
    var author: Person
    var rating: Int
    var text: String
    var dateLabel: String
    var itemTitle: String
}

// MARK: - Formatting helpers

enum BDate {
    static func range(_ start: Date, _ end: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "d MMM yyyy"
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }

    static func short(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }

    static func weekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "EEE d MMM"
        return f.string(from: date)
    }

    static func time(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
