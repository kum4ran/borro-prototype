import Foundation

/// Every name, item, price and date the app shows. Views read from here; they never invent data.
enum MockData {
    // MARK: People

    static let james = User(
        id: "james", name: "James", fullName: "James Chong", photo: .james,
        rating: "3.5", reviewCount: 45, credibility: 72, credibilityLabel: "Moderate",
        area: Scenario.area, ageAndCity: "21 · Singapore",
        bio: "Co-living, campus days & sharing more.")

    static let thomas = User(
        id: "thomas", name: "Thomas", fullName: "Thomas", photo: .thomas,
        rating: "5.0", reviewCount: 10, credibility: 86, credibilityLabel: "High", area: Scenario.area)

    static let steamerDescription = "Freshen up your outfit in minutes. Lightweight handheld steamer, ready in 30 seconds. Includes a heat-resistant mitt."

    // CONFLICT: Figma reuses avatars across lenders (Matthew and Lebron share one on 1.1,
    // 1.3 labels the JBL lender "Thomas"). Each lender gets one fixed avatar here.
    static let kumaran = User(id: "kumaran", name: "Kumaran", fullName: "Kumaran", photo: .kumaran)
    static let matthew = User(id: "matthew", name: "Matthew", fullName: "Matthew", photo: .matthew)
    static let jessica = User(id: "jessica", name: "Jessica", fullName: "Jessica", photo: .jessica)
    static let lebron = User(id: "lebron", name: "Lebron", fullName: "Lebron", photo: .lebron)
    static let mei = User(id: "mei", name: "Mei", fullName: "Mei", photo: .mei, credibility: 86, credibilityLabel: "High")
    static let darren = User(id: "darren", name: "Darren", fullName: "Darren", photo: .manOne, credibility: 86, credibilityLabel: "High")
    static let andrew = User(id: "andrew", name: "Andrew", fullName: "Andrew", photo: .andrew)

    // MARK: Listings

    static let steamer = Listing(
        id: "steamer", title: "Garment Steamer", owner: thomas, photo: .steamerDesk,
        rating: "★ 5.0 (10 reviews)", area: Scenario.area, availableDates: "13–27 Oct 2026",
        availabilityLabel: "⚡ 120 m | available now", needItNow: true, withinOneKm: true)

    static let jbl = Listing(
        id: "jbl", title: "JBL Speaker", owner: kumaran, photo: .speakerConcert,
        rating: "★ 5.0 (10 reviews)", area: Scenario.area, availableDates: "17–25 Oct 2026",
        availabilityLabel: "⚡ 400 m | available now", needItNow: true)

    static let projector = Listing(
        id: "projector", title: "Portable Projector", owner: matthew, photo: .projector,
        rating: "★ 4.7 (14 reviews)", area: "Bras Basah Rd", availableDates: "16–23 Oct 2026")

    static let projectorScreen = Listing(
        id: "screen", title: "Projector Screen", owner: jessica, photo: .projectorScreen,
        rating: "★ 4.6 (20 reviews)", area: "Plaza Singapura", availableDates: "18–20 Oct 2026")

    static let football = Listing(
        id: "football", title: "Football", owner: lebron, photo: .football,
        rating: "★ 5.0 (10 reviews)", area: "West Wing", availableDates: "17–21 Oct 2026")

    static let xiaomiSteamer = Listing(
        id: "xiaomi", title: "Xiaomi Steamer", owner: mei, photo: .steamerTravel,
        rating: "★ 4.7 (18 reviews)", area: "Tampines Hub", availableDates: "16–24 Oct 2026",
        availabilityLabel: "⚡ 16.8 km | available now", needItNow: true)

    static let camera = Listing(
        id: "camera", title: "Digital Camera", owner: andrew, photo: .camera,
        rating: "★ 4.9 (31 reviews)", area: "Punggol Waterway", availableDates: "15–22 Oct 2026",
        availabilityLabel: "⚡ 13.5 km | available now", needItNow: true)

    /// 1.1 Home grid.
    static let homeFeed = [jbl, projector, projectorScreen, football]
    /// 1.2 Need it Now on.
    static let needItNowFeed = [jbl, xiaomiSteamer, steamer, camera]
    /// 1.5 Results within 1 km.
    static let resultsFeed = [steamer]

    // MARK: The borrowing

    static let request = BorrowRequest(
        reference: Scenario.reference, listing: steamer, borrower: james, lender: thomas,
        dates: Scenario.borrowDatesShort, mode: "Borrow Now")

    static let agreement = Agreement(
        request: request, pickUp: Scenario.pickUp, returnBy: Scenario.returnShort,
        place: Scenario.meetUpPlace, deposit: Scenario.depositAmount)

    /// Other requests on 3.2 (only James's leads anywhere).
    static let otherRequests: [(user: User, dates: String, urgent: Bool)] = [
        (mei, "20–21 Oct 2026", true), (darren, "20–21 Oct 2026", false),
    ]

    // MARK: Reviews and credibility

    static let jamesReviews = [
        Review(id: "r1", author: "Kumaran", stars: 4, text: "Returned the item cleaned.", date: "12 Oct 2026"),
        Review(id: "r2", author: "Maria", stars: 3, text: "Good communication, but the return was a little late.", date: "8 Oct 2026"),
        Review(id: "r3", author: "Regen", stars: 4, text: "Careful with my drill. He would lend the item again.", date: "2 Oct 2026"),
    ]

    static let jamesCredibility = [
        CredibilityFactor(label: "Successful transactions", score: 80),
        CredibilityFactor(label: "On-time returns", score: 65),
        CredibilityFactor(label: "Item condition after return", score: 78),
        CredibilityFactor(label: "Communication", score: 60),
        CredibilityFactor(label: "Cancellation rate", score: 85),
        CredibilityFactor(label: "Reviews", score: 64),
    ]

    // MARK: Chat (4.9)

    static let chat = [
        ChatMessage(id: "c1", text: "Hi James! Meet at \(Scenario.meetUpPlace) at \(Scenario.pickUpTime) for the steamer?", time: "6:42 pm", mine: false),
        // CONFLICT: Figma says "return it tomorrow by 10 am"; the scenario return time wins.
        ChatMessage(id: "c2", text: "Sure, see you there! I’ll return it tomorrow by \(Scenario.returnTime).", time: "6:43 pm", mine: true, read: true),
        ChatMessage(id: "c3", text: "Lovely, please take a look at this agreement!", time: "6:44 pm", mine: false),
    ]

    // MARK: Meet-up time pills (Figma collection "Borro times")

    static let pickUpDay = "Sun 18 Oct"
    static let returnDay = "Mon 19 Oct"

    static let pickUpOptions = [
        TimeOption(id: "up0", label: "7 pm", day: pickUpDay, time: "7:00 pm"),
        TimeOption(id: "up1", label: "7:30 pm", day: pickUpDay, time: "7:30 pm"),
    ]

    // CONFLICT: Figma offers 9 am, 10 am and 10:30 am. The scenario return is Monday 11:00 pm,
    // so the middle pill is the scenario time (Scenario.returnTime) with one slot either side.
    static let returnOptions = [
        TimeOption(id: "rt0", label: "10 pm", day: returnDay, time: "10:00 pm"),
        TimeOption(id: "rt1", label: Scenario.returnPill, day: returnDay, time: Scenario.returnTime),
        TimeOption(id: "rt2", label: "11:30 pm", day: returnDay, time: "11:30 pm"),
    ]

    /// Pill lists as one line ("7, 7:30 pm" / "10, 11, 11:30 pm").
    static let pickUpOffer = "7, 7:30 pm"
    static let returnOffer = "10, 11, 11:30 pm"
}
