import SwiftUI

// MARK: - Scenario fixtures
//
// One coherent story, matching the Figma: James borrows Thomas's garment
// steamer in Bencoolen St, Singapore, in October 2026.

enum BPeople {
    static let james = Person(
        id: "james", name: "James Tan", handle: "@james",
        photo: .james, rating: 4.9, reviewCount: 24, credibility: 92,
        location: "Bencoolen St",
        bio: "New here. Borrowing what I need instead of buying it.",
        itemsLent: 0, itemsBorrowed: 12
    )

    static let thomas = Person(
        id: "thomas", name: "Thomas Lim", handle: "@thomas",
        photo: .thomas, rating: 5.0, reviewCount: 10, credibility: 86,
        location: "Bencoolen St",
        bio: "Lending the things I bought for one occasion. Steamer, projector, and a very good speaker.",
        itemsLent: 7, itemsBorrowed: 3
    )

    static let kumaran = Person(
        id: "kumaran", name: "Kumaran", handle: "@kumaran",
        photo: .kumaran, rating: 5.0, reviewCount: 10, credibility: 88,
        location: "Bencoolen St", itemsLent: 4
    )

    static let matthew = Person(
        id: "matthew", name: "Matthew", handle: "@matthew",
        photo: .matthew, rating: 4.7, reviewCount: 14, credibility: 81,
        location: "Bras Basah Rd", itemsLent: 3
    )

    static let jessica = Person(
        id: "jessica", name: "Jessica", handle: "@jessica",
        photo: .jessica, rating: 4.6, reviewCount: 20, credibility: 79,
        location: "Plaza Singapura", itemsLent: 6
    )

    static let lebron = Person(
        id: "lebron", name: "Lebron", handle: "@lebron",
        photo: .lebron, rating: 5.0, reviewCount: 10, credibility: 84,
        location: "West Wing", itemsLent: 2
    )

    static let mei = Person(
        id: "mei", name: "Mei", handle: "@mei",
        photo: .mei, rating: 4.7, reviewCount: 18, credibility: 83,
        location: "Tampines Hub", itemsLent: 5
    )

    static let andrew = Person(
        id: "andrew", name: "Andrew", handle: "@andrew",
        photo: .andrew, rating: 4.9, reviewCount: 31, credibility: 90,
        location: "Punggol Waterway", itemsLent: 9
    )

    static let all: [Person] = [james, thomas, kumaran, matthew, jessica, lebron, mei, andrew]
}

enum BItems {
    static let steamer = Item(
        id: "steamer",
        title: "Garment Steamer",
        subtitle: "Handheld",
        owner: BPeople.thomas,
        photo: .steamer,
        photos: [.steamer, .steamerDesk, .steamerShirt],
        location: "Bencoolen St",
        rating: 5.0, reviewCount: 10,
        distance: "120 m",
        availability: "Available",
        pricePerDay: 4, deposit: 10,
        description: "Freshen up your outfit in minutes. Lightweight handheld steamer, ready in 30 seconds. Includes a heat-resistant mitt.",
        condition: "Like new",
        category: "Home",
        busyDays: [16, 22],
        pickupNote: "Bencoolen St · meet at the lobby"
    )

    static let jbl = Item(
        id: "jbl", title: "JBL Speaker", subtitle: "Party speaker",
        owner: BPeople.kumaran, photo: .jblSpeaker,
        location: "Bencoolen St", rating: 5.0, reviewCount: 10,
        distance: "400 m", availability: "Available",
        pricePerDay: 12, deposit: 40,
        description: "Bought it for one apartment party. It's been quiet since.",
        condition: "Good", category: "Music"
    )

    static let projector = Item(
        id: "projector", title: "Portable Projector", subtitle: "Anker Nebula",
        owner: BPeople.matthew, photo: .projector,
        location: "Bras Basah Rd", rating: 4.7, reviewCount: 14,
        distance: "700 m", availability: "Available",
        pricePerDay: 10, deposit: 25,
        description: "Film nights, sorted. Fits on a bookshelf.",
        condition: "Good", category: "Tech"
    )

    static let screen = Item(
        id: "screen", title: "Projector Screen", subtitle: "100 inch",
        owner: BPeople.jessica, photo: .projectorScreen,
        location: "Plaza Singapura", rating: 4.6, reviewCount: 20,
        distance: "1.2 km", availability: "Available",
        pricePerDay: 6, deposit: 15,
        description: "Projector screen with tripod stand.",
        condition: "Good", category: "Tech"
    )

    static let football = Item(
        id: "football", title: "Football", subtitle: "Size 5",
        owner: BPeople.lebron, photo: .football,
        location: "West Wing", rating: 5.0, reviewCount: 10,
        distance: "1.6 km", availability: "Available",
        pricePerDay: 2, deposit: 5,
        description: "Match ball, used twice.",
        condition: "Good", category: "Outdoors"
    )

    static let camera = Item(
        id: "camera", title: "Digital Camera", subtitle: "Fujifilm X100",
        owner: BPeople.andrew, photo: .camera,
        location: "Punggol Waterway", rating: 4.9, reviewCount: 31,
        distance: "13.5 km", availability: "Available now",
        pricePerDay: 15, deposit: 60,
        description: "Twelve thousand photos on a phone and not one printed. Borrow a real camera.",
        condition: "Like new", category: "Tech"
    )

    static let xiaomi = Item(
        id: "xiaomi", title: "Xiaomi Steamer", subtitle: "Travel steamer",
        owner: BPeople.mei, photo: .steamerDesk,
        location: "Tampines Hub", rating: 4.7, reviewCount: 18,
        distance: "16.8 km", availability: "Available now",
        pricePerDay: 3, deposit: 8,
        description: "Compact steamer for trips.",
        condition: "Good", category: "Home"
    )

    static let feed: [Item] = [jbl, projector, screen, football]

    static let needItNow: [Item] = [jbl, xiaomi, steamer, camera]
}

// MARK: - Global store

final class BorroStore: ObservableObject {
    @Published var me: Person = BPeople.james
    @Published var activeItem: Item = BItems.steamer
    @Published var mode: BorrowMode = .now
    @Published var searchQuery: String = ""
    @Published var location: String = "Bencoolen St"
    @Published var radiusKm: Double = 1

    // Scenario state shared across flows
    @Published var request: BorrowRequest
    @Published var chats: [ChatMessage]
    @Published var timeline: [TimelineStage]
    @Published var handoverPhotos: [BPhoto]
    @Published var lenderPhotos: [BPhoto]
    @Published var reviewRating: Int = 0
    @Published var savedItemIDs: Set<String> = []

    init() {
        let cal = Calendar.current
        let start = cal.date(from: DateComponents(year: 2026, month: 10, day: 17))!
        let end = cal.date(from: DateComponents(year: 2026, month: 10, day: 19))!
        request = BorrowRequest(
            id: "REQ-1042",
            item: BItems.steamer,
            borrower: BPeople.james,
            lender: BPeople.thomas,
            status: .pending,
            mode: .now,
            dates: DateRange(start: start, end: end),
            returnDates: DateRange(start: end, end: end),
            handoverCode: "4821",
            borrowerCode: "7390",
            note: "Need it for an interview on Monday.",
            total: 18
        )
        chats = [
            ChatMessage(id: "m1", text: "Hi Thomas! Is the steamer free this weekend?", isMine: true, time: "10:04"),
            ChatMessage(id: "m2", text: "It is. I can meet you at the lobby on Saturday morning.", isMine: false, time: "10:06"),
            ChatMessage(id: "m3", text: "Saturday works. Thank you!", isMine: true, time: "10:07")
        ]
        timeline = [
            TimelineStage(id: "t0", title: "Request sent", subtitle: "Waiting for Thomas", dateLabel: "Today · 10:00", isDone: true),
            TimelineStage(id: "t1", title: "Agreement", subtitle: "Deposit and care note", dateLabel: "Next", isDone: false),
            TimelineStage(id: "t2", title: "Handover", subtitle: "Codes and photos", dateLabel: "Sat 17 Oct", isDone: false),
            TimelineStage(id: "t3", title: "Return", subtitle: "Back to Thomas", dateLabel: "Mon 19 Oct", isDone: false),
            TimelineStage(id: "t4", title: "Refund", subtitle: "Deposit returned", dateLabel: "Within 24h", isDone: false)
        ]
        handoverPhotos = [.steamer, .steamerShirt]
        lenderPhotos = [.steamerDesk]
    }

    func toggleSaved(_ item: Item) {
        if savedItemIDs.contains(item.id) { savedItemIDs.remove(item.id) }
        else { savedItemIDs.insert(item.id) }
    }

    func isSaved(_ item: Item) -> Bool { savedItemIDs.contains(item.id) }

    func timeline(with statuses: [String]) -> [TimelineStage] { timeline }
}
