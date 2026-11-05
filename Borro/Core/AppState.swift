import SwiftUI
import Observation

/// The single source of truth. Mirrors the Figma variables: "Borro status",
/// "Borro photos", "Borro times" and "code timer". Views read it; only its methods change it.
@Observable
@MainActor
final class AppState {
    // Borro status
    private(set) var status: BorrowStatus = .pending
    private(set) var deposit: DepositState = .unpaid

    // Who is holding the phone (the prototype is one phone playing both roles)
    private(set) var currentUser: Role = .james
    private(set) var roleBanner: String?

    // Borro photos
    private(set) var photos: [PhotoSetID: PhotoSet] = [:]

    // Borrowing dates (2.2) and the handover schedule (4.2–4.12, "Borro times")
    private(set) var borrowStart = Scenario.defaultBorrowStart
    private(set) var borrowEnd = Scenario.defaultBorrowEnd
    private(set) var pickUpDay = Scenario.defaultBorrowStart
    private(set) var returnDay = Scenario.defaultBorrowEnd
    private(set) var pickUpOffers = MockData.defaultPickUpOffers
    private(set) var returnOffers = MockData.defaultReturnOffers
    private(set) var pickUpChoice: TimeOfDay?
    private(set) var returnChoice: TimeOfDay?
    private(set) var meetUpSpot = MeetingSpot.blockA
    private(set) var meetUpChosen = false

    // Search radius (1.4) and deposit payment method (5.2)
    private(set) var radius = RadiusStop.km1
    private(set) var paymentMethod = PaymentMethod.payNow

    // Code countdown ("refreshes in 0:45"), one timer for every code screen
    private(set) var codeSecondsLeft = Scenario.codeRefreshSeconds

    // Lender code entry on 6.11 / 6.12
    private(set) var codeAttemptFailed = false

    // Discover
    private(set) var needItNow = false
    private(set) var likedListingIDs: Set<String> = []

    // Agreement and handover progress
    private(set) var agreedToTerms = false
    private(set) var dropOffSaved = false
    private(set) var collected = false
    private(set) var returnCodeVerified = false

    // Reviews
    private(set) var jamesRatingOfThomas = 0
    private(set) var thomasRatingOfJames = 0

    init() {}

    /// Restores the launch state (demo menu "Reset demo").
    func reset() {
        status = .pending
        deposit = .unpaid
        currentUser = .james
        roleBanner = nil
        photos = [:]
        borrowStart = Scenario.defaultBorrowStart
        borrowEnd = Scenario.defaultBorrowEnd
        pickUpDay = Scenario.defaultBorrowStart
        returnDay = Scenario.defaultBorrowEnd
        pickUpOffers = MockData.defaultPickUpOffers
        returnOffers = MockData.defaultReturnOffers
        pickUpChoice = nil
        returnChoice = nil
        meetUpSpot = .blockA
        meetUpChosen = false
        radius = .km1
        paymentMethod = .payNow
        codeSecondsLeft = Scenario.codeRefreshSeconds
        codeAttemptFailed = false
        needItNow = false
        likedListingIDs = []
        jamesRatingOfThomas = 0
        thomasRatingOfJames = 0
        agreedToTerms = false
        dropOffSaved = false
        collected = false
        returnCodeVerified = false
        thomasCategoryStars = [:]
        jamesCategoryStars = [:]
        wishlistRemoved = []
        thomasReviewSubmitted = false
    }

    // MARK: Status

    func setStatus(_ new: BorrowStatus) { status = new }

    /// Borrower line on My Borrowing (2.4). Strings from the Figma "borrower detail" variable.
    var borrowerDetail: String {
        let place = meetUpPlace
        let ret = "\(returnDay.medium), \(returnTime)"
        switch status {
        case .pending, .handoverPending: return "Pick up: \(pickUpDay.medium), \(pickUpTime) · \(place)"
        case .onLoan: return "Return by: \(ret) · \(place)"
        case .returnPending: return "Returning: \(ret) · \(place)"
        case .returned: return "Returned: \(ret) · \(place)"
        }
    }

    /// Lender line on My Lending (9.x). Strings from the Figma "lender detail" variable.
    var lenderDetail: String {
        let due = "\(returnDay.medium), \(returnTime.uppercased())"
        switch status {
        case .pending: return "James requested \(borrowRange) · Awaiting your reply"
        case .handoverPending: return "Handover to James · \(pickUpDay.medium), \(pickUpTime.uppercased()) · \(meetUpPlace)"
        case .onLoan: return "With James · Due \(due)"
        case .returnPending: return "Awaiting return from James · Due \(due)"
        case .returned: return "Returned by James · \(due)"
        }
    }

    // MARK: Deposit

    func choosePaymentMethod(_ method: PaymentMethod) { paymentMethod = method }

    /// 5.2c → 5.2d. Paying also ticks the agreement box, as Figma's 5.5 shows.
    func depositPaid() {
        deposit = .held
        agreedToTerms = true
    }

    func toggleAgreedToTerms() { agreedToTerms.toggle() }

    var canSubmitAgreement: Bool { deposit == .held && agreedToTerms }

    /// Deposit line on the timelines.
    var depositStatusText: String {
        switch deposit {
        case .unpaid: return "Awaiting deposit"
        case .held: return status == .returned ? "Refund processing" : "Held safely"
        case .refunded: return "Refunded"
        }
    }

    // MARK: Handover progress

    func saveDropOff() { dropOffSaved = true }
    func markCollected() { collected = true }

    enum TimelineStage: Int, CaseIterable {
        case agreed, meetUp, lending, returned

        var title: String {
            switch self {
            case .agreed: return "Agreed"
            case .meetUp: return "Meet-up"
            case .lending: return "Lending"
            case .returned: return "Return"
            }
        }
    }

    var timelineStage: TimelineStage {
        switch status {
        case .pending, .handoverPending: return dropOffSaved ? .meetUp : .agreed
        case .onLoan, .returnPending: return .lending
        case .returned: return .returned
        }
    }
    func depositRefunded() { deposit = .refunded }

    // MARK: Role

    /// Switches the simulated device owner and shows "Now viewing as …".
    func switchRole(to role: Role) {
        guard role != .both, role != currentUser else { return }
        currentUser = role
        roleBanner = "Now viewing as \(role.displayName)"
    }

    func clearRoleBanner() { roleBanner = nil }

    // MARK: Photos

    func photoSet(_ id: PhotoSetID) -> PhotoSet { photos[id] ?? PhotoSet() }

    func addPhoto(_ slot: PhotoSlot, to id: PhotoSetID) {
        var set = photoSet(id)
        switch slot {
        case .front: set.hasFront = true
        case .back: set.hasBack = true
        case .extra: set.hasExtra = true
        }
        photos[id] = set
    }

    func removePhoto(_ slot: PhotoSlot, from id: PhotoSetID) {
        var set = photoSet(id)
        switch slot {
        case .front: set.hasFront = false
        case .back: set.hasBack = false
        case .extra: set.hasExtra = false
        }
        photos[id] = set
    }

    // MARK: Borrowing dates (2.2)

    /// Days James can pick: from today (Sun 18 Oct) to the end of Thomas's availability, 7 days at most.
    func canBorrow(_ day: OctDay) -> Bool {
        Scenario.borrowableDays.contains(day.day)
    }

    /// Calendar tap: a first tap starts a new range, a later day extends it (7 days at most).
    func selectBorrowDay(_ day: OctDay) {
        guard canBorrow(day) else { return }
        if borrowStart != borrowEnd || day < borrowStart || day.day - borrowStart.day > Scenario.maxBorrowDays {
            borrowStart = day
            borrowEnd = day
        } else {
            borrowEnd = day
        }
        resetSchedule()
    }

    var borrowNights: Int { borrowEnd.day - borrowStart.day }
    /// "1 day", "3 days", "Same day"
    var durationText: String {
        switch borrowNights {
        case 0: return "Same day"
        case 1: return "1 day"
        default: return "\(borrowNights) days"
        }
    }
    /// "18–19 Oct 2026"
    var borrowRange: String { borrowStart == borrowEnd ? borrowStart.withYear : "\(borrowStart.day)–\(borrowEnd.withYear)" }
    /// "18–19 Oct"
    var borrowRangeShort: String { borrowStart == borrowEnd ? borrowStart.short : "\(borrowStart.day)–\(borrowEnd.short)" }
    /// "18 → 19 Oct 2026"
    var borrowArrow: String { borrowStart == borrowEnd ? borrowStart.withYear : "\(borrowStart.day) → \(borrowEnd.withYear)" }
    /// "18 Oct → 19 Oct · 1 day"
    var borrowSummary: String {
        borrowStart == borrowEnd ? "\(borrowStart.short) · \(durationText)" : "\(borrowStart.short) → \(borrowEnd.short) · \(durationText)"
    }
    var borrowDays: Set<Int> { Set(borrowStart.day...borrowEnd.day) }

    // MARK: Handover schedule (4.2–4.12)

    /// New dates clear the times and spot that were planned for the old ones.
    private func resetSchedule() {
        pickUpDay = borrowStart
        returnDay = borrowEnd
        pickUpOffers = MockData.defaultPickUpOffers
        returnOffers = MockData.defaultReturnOffers
        pickUpChoice = nil
        returnChoice = nil
    }

    func choosePickUpDay(_ day: OctDay) {
        guard borrowDays.contains(day.day) else { return }
        pickUpDay = day
        if returnDay < day { returnDay = day }
        pickUpChoice = nil
        returnChoice = nil
    }

    func chooseReturnDay(_ day: OctDay) {
        guard borrowDays.contains(day.day), day >= pickUpDay else { return }
        returnDay = day
        returnChoice = nil
    }

    /// Return times on the pick-up day must come after the earliest pick-up time.
    func canOfferReturn(_ time: TimeOfDay) -> Bool {
        guard returnDay == pickUpDay, let earliest = pickUpOffers.min() else { return true }
        return time > earliest
    }

    func addPickUpOffer(_ time: TimeOfDay) {
        guard !pickUpOffers.contains(time) else { return }
        pickUpOffers = (pickUpOffers + [time]).sorted()
        returnOffers.removeAll { !canOfferReturn($0) }
    }

    func removePickUpOffer(_ time: TimeOfDay) {
        pickUpOffers.removeAll { $0 == time }
        if pickUpChoice == time { pickUpChoice = nil }
    }

    func clearPickUpOffers() {
        pickUpOffers = []
        pickUpChoice = nil
    }

    func addReturnOffer(_ time: TimeOfDay) {
        guard !returnOffers.contains(time), canOfferReturn(time) else { return }
        returnOffers = (returnOffers + [time]).sorted()
    }

    func removeReturnOffer(_ time: TimeOfDay) {
        returnOffers.removeAll { $0 == time }
        if returnChoice == time { returnChoice = nil }
    }

    func clearReturnOffers() {
        returnOffers = []
        returnChoice = nil
    }

    func choosePickUp(_ time: TimeOfDay) { if pickUpOffers.contains(time) { pickUpChoice = time } }
    func chooseReturn(_ time: TimeOfDay) { if returnOffers.contains(time) { returnChoice = time } }
    var bothTimesChosen: Bool { pickUpChoice != nil && returnChoice != nil }
    var timesButtonLabel: String { bothTimesChosen ? "Confirm times" : "Choose pick-up and return" }

    /// Agreed pick-up time. Scenario default (7:30 pm) until Thomas picks a pill.
    var pickUpTime: String { (pickUpChoice ?? Scenario.defaultPickUpTime).label }
    /// Agreed return time. Defaults to Scenario.returnTime (10:30 am) until Thomas picks a pill.
    var returnTime: String { (returnChoice ?? Scenario.defaultReturnTime).label }
    /// "Sun 18 Oct · 7:30 pm"
    var pickUpLabel: String { "\(pickUpDay.medium) · \(pickUpTime)" }
    /// "Mon 19 Oct · 10:30 am"
    var returnLabel: String { "\(returnDay.medium) · \(returnTime)" }
    /// "18 Oct · 7:30 pm"
    var pickUpShort: String { "\(pickUpDay.short) · \(pickUpTime)" }
    var returnShort: String { "\(returnDay.short) · \(returnTime)" }
    /// "18 Oct, 7:30 pm → 19 Oct, 10:30 am"
    var agreementDates: String { "\(pickUpDay.short), \(pickUpTime) → \(returnDay.short), \(returnTime)" }
    /// James's offers in one line: "7, 7:30 pm"
    var pickUpOfferText: String { TimeOfDay.compactList(pickUpOffers) }
    var returnOfferText: String { TimeOfDay.compactList(returnOffers) }
    var canSendProposal: Bool { !pickUpOffers.isEmpty && !returnOffers.isEmpty }

    // MARK: Meet-up spot (4.6, 4.13)

    var meetUpPlace: String { meetUpSpot.name }

    func chooseMeetUpSpot(_ spot: MeetingSpot) {
        meetUpSpot = spot
        meetUpChosen = true
    }

    // MARK: Search radius (1.4)

    func setRadius(_ stop: RadiusStop) { radius = stop }

    /// Steamers within the chosen radius (1.5).
    var steamerResults: [Listing] {
        MockData.steamerListings.filter { $0.distanceMetres <= radius.metres }
    }

    // MARK: Code countdown

    var codeTimerLabel: String { String(format: "refreshes in %d:%02d", codeSecondsLeft / 60, codeSecondsLeft % 60) }

    /// One tick: counts down to 0:00, then restarts at 0:45.
    func tickCode() {
        codeSecondsLeft = codeSecondsLeft == 0 ? Scenario.codeRefreshSeconds : codeSecondsLeft - 1
    }

    /// Runs for the app's lifetime; started once from BorroApp.
    func runCodeTimer() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            tickCode()
        }
    }

    // MARK: Codes

    /// Validates the lender code James types on 6.11.
    func submitLenderCode(_ code: String) -> Bool {
        let ok = code == Scenario.lenderCode
        codeAttemptFailed = !ok
        return ok
    }

    /// Validates the borrower code Thomas types on 7.2.
    func submitBorrowerCode(_ code: String) -> Bool {
        returnCodeVerified = code == Scenario.borrowerCode
        return returnCodeVerified
    }

    func clearCodeError() { codeAttemptFailed = false }

    // MARK: Discover

    func setNeedItNow(_ on: Bool) { needItNow = on }

    func toggleLike(_ listing: Listing) {
        if likedListingIDs.contains(listing.id) { likedListingIDs.remove(listing.id) }
        else { likedListingIDs.insert(listing.id) }
    }

    func isLiked(_ listing: Listing) -> Bool { likedListingIDs.contains(listing.id) }

    /// Wishlist (11.4): Figma's saved items plus anything liked since, minus anything unliked there.
    private(set) var wishlistRemoved: Set<String> = []

    var wishlist: [Listing] {
        let liked = (MockData.homeFeed + MockData.needItNowFeed).filter { isLiked($0) }
        var seen = Set<String>()
        return (MockData.wishlist + liked).filter { seen.insert($0.id).inserted }
    }

    func isWished(_ listing: Listing) -> Bool {
        !wishlistRemoved.contains(listing.id) && (MockData.wishlist.contains(listing) || isLiked(listing))
    }

    func toggleWish(_ listing: Listing) {
        if isWished(listing) {
            wishlistRemoved.insert(listing.id)
            likedListingIDs.remove(listing.id)
        } else {
            wishlistRemoved.remove(listing.id)
            likedListingIDs.insert(listing.id)
        }
    }

    // MARK: Reviews

    /// Five rated categories per review (8.2, 8.6).
    static let reviewCategories = ["Overall rating", "Item condition", "Arrangement", "Punctuality", "Friendliness"]
    private(set) var thomasCategoryStars: [String: Int] = [:]
    private(set) var jamesCategoryStars: [String: Int] = [:]

    /// Fills every category (Figma's single "Five star controls" tap) or sets one.
    func rateThomas(_ stars: Int, category: String? = nil) {
        if let category { thomasCategoryStars[category] = stars }
        else { for c in Self.reviewCategories { thomasCategoryStars[c] = stars } }
        jamesRatingOfThomas = thomasCategoryStars["Overall rating"] ?? stars
    }

    func rateJames(_ stars: Int, category: String? = nil) {
        if let category { jamesCategoryStars[category] = stars }
        else { for c in Self.reviewCategories { jamesCategoryStars[c] = stars } }
        thomasRatingOfJames = jamesCategoryStars["Overall rating"] ?? stars
    }

    private(set) var thomasReviewSubmitted = false
    func submitThomasReview() { thomasReviewSubmitted = true }

    var thomasReviewComplete: Bool { Self.reviewCategories.allSatisfy { (thomasCategoryStars[$0] ?? 0) > 0 } }
    var jamesReviewComplete: Bool { Self.reviewCategories.allSatisfy { (jamesCategoryStars[$0] ?? 0) > 0 } }
}
