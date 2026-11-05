import XCTest
@testable import Borro

/// State rules from the brief, section 6.
@MainActor
final class StateRulesTests: XCTestCase {
    private var state: AppState!
    private var router: Router!

    override func setUp() async throws {
        state = AppState()
        router = Router()
        router.appState = state
    }

    // MARK: Status

    func testStatusFollowsTheStoryTransitions() {
        XCTAssertEqual(state.status, .pending)
        router.go(.s2_1); router.go(.s2_2)
        state.setStatus(.pending)                 // 2.2 Send Request
        XCTAssertEqual(state.status, .pending)
        state.setStatus(.handoverPending)         // 3.7 Confirm
        XCTAssertEqual(state.status.tone, .amber)
        state.setStatus(.onLoan)                  // 6.18 Confirm submission
        XCTAssertEqual(state.status.tone, .blue)
        state.setStatus(.returnPending)           // 6.20 Ready to Return
        XCTAssertEqual(state.status.tone, .amber)
        state.setStatus(.returned)                // 7.4 Confirm submission
        XCTAssertEqual(state.status.tone, .green)
    }

    func testDetailLinesMatchFigmaVariables() {
        XCTAssertEqual(state.borrowerDetail, "Pick up: Sun 18 Oct, 7:30 pm · Block A Security Desk")
        XCTAssertEqual(state.lenderDetail, "James requested 18–19 Oct 2026 · Awaiting your reply")
        state.setStatus(.handoverPending)
        XCTAssertEqual(state.lenderDetail, "Handover to James · Sun 18 Oct, 7:30 PM · Block A Security Desk")
        state.setStatus(.onLoan)
        XCTAssertEqual(state.borrowerDetail, "Return by: Mon 19 Oct, \(Scenario.returnTime) · Block A Security Desk")
        XCTAssertEqual(state.lenderDetail, "With James · Due Mon 19 Oct, \(Scenario.defaultReturnTime.caps)")
    }

    func testMyBorrowingCardOpensPushWhilePendingThenHandover() {
        // The 2.4 card rule: Pending → 3.1, anything else → 6.1.
        XCTAssertEqual(state.status == .pending ? Screen.s3_1 : .s6_1, .s3_1)
        state.setStatus(.handoverPending)
        XCTAssertEqual(state.status == .pending ? Screen.s3_1 : .s6_1, .s6_1)
    }

    // MARK: Deposit

    func testDepositMovesFromUnpaidToHeldToRefunded() {
        XCTAssertEqual(state.deposit, .unpaid)
        XCTAssertFalse(state.canSubmitAgreement)
        XCTAssertEqual(state.depositStatusText, "Awaiting deposit")
        state.depositPaid()
        XCTAssertEqual(state.deposit, .held)
        XCTAssertTrue(state.canSubmitAgreement)
        XCTAssertEqual(state.depositStatusText, "Held safely")
        state.setStatus(.returned)
        XCTAssertEqual(state.depositStatusText, "Refund processing")
        state.depositRefunded()
        XCTAssertEqual(state.deposit, .refunded)
        XCTAssertEqual(state.depositStatusText, "Refunded")
    }

    // MARK: Countdown

    func testCountdownStartsAt45AndWrapsAfterZero() {
        XCTAssertEqual(state.codeTimerLabel, "refreshes in 0:45")
        for _ in 0..<45 { state.tickCode() }
        XCTAssertEqual(state.codeTimerLabel, "refreshes in 0:00")
        state.tickCode()
        XCTAssertEqual(state.codeTimerLabel, "refreshes in 0:45")
    }

    // MARK: Codes

    func testLenderCodeValidation() {
        XCTAssertFalse(state.submitLenderCode("1234"))
        XCTAssertTrue(state.codeAttemptFailed)
        XCTAssertFalse(state.submitLenderCode(Scenario.borrowerCode))
        XCTAssertTrue(state.submitLenderCode("6767"))
        XCTAssertFalse(state.codeAttemptFailed)
    }

    func testBorrowerCodeValidation() {
        XCTAssertFalse(state.submitBorrowerCode("6767"))
        XCTAssertFalse(state.returnCodeVerified)
        XCTAssertTrue(state.submitBorrowerCode("8482"))
        XCTAssertTrue(state.returnCodeVerified)
    }

    // MARK: Photos

    func testFrontPhotoIsRequiredAndBackIsOptional() {
        XCTAssertFalse(PhotoRules.isComplete(state.photoSet(.dropOff)))
        state.addPhoto(.back, to: .dropOff)
        XCTAssertFalse(PhotoRules.isComplete(state.photoSet(.dropOff)), "back alone is not enough")
        state.addPhoto(.front, to: .dropOff)
        XCTAssertEqual(PhotoRules.isComplete(state.photoSet(.dropOff)), true)
        state.removePhoto(.front, from: .dropOff)
        XCTAssertFalse(PhotoRules.isComplete(state.photoSet(.dropOff)))
    }

    func testPhotoSetsAreIndependent() {
        state.addPhoto(.front, to: .dropOff)
        XCTAssertFalse(state.photoSet(.collection).hasFront)
        XCTAssertFalse(state.photoSet(.returned).hasFront)
    }

    func testPhotoFlowRoutesToTheRightVariant() {
        XCTAssertEqual(PhotoFlow.dropOff.screen(for: .back, filled: true), .s6_5a)
        XCTAssertEqual(PhotoFlow.collection.screen(for: .extra, filled: false), .s6_14d)
        XCTAssertEqual(PhotoFlow.returned.screen(for: .extra, filled: true), .s7_3)
        XCTAssertEqual(PhotoFlow.dropOff.nameSheet(for: .back), .s6_3a)
        XCTAssertNil(PhotoFlow.collection.nameSheet(for: .front), "James adds photos without a name sheet")
    }

    // MARK: Times

    func testConfirmTimesNeedsBothChoices() {
        XCTAssertEqual(state.timesButtonLabel, "Choose pick-up and return")
        XCTAssertFalse(state.bothTimesChosen)
        state.choosePickUp(MockData.defaultPickUpOffers[1])
        XCTAssertFalse(state.bothTimesChosen)
        state.chooseReturn(Scenario.defaultReturnTime)
        XCTAssertTrue(state.bothTimesChosen)
        XCTAssertEqual(state.timesButtonLabel, "Confirm times")
        XCTAssertEqual(state.pickUpLabel, "Sun 18 Oct · 7:30 pm")
        XCTAssertEqual(state.returnLabel, "Mon 19 Oct · \(Scenario.returnTime)")
    }

    // MARK: Option-driven schedule

    func testOctoberWeekdaysAreComputedFromTheFixedMonth() {
        XCTAssertEqual(OctDay(day: 1).medium, "Thu 1 Oct")
        XCTAssertEqual(OctDay(day: 18).medium, "Sun 18 Oct")
        XCTAssertEqual(OctDay(day: 19).lockScreen, "Monday, 19 October")
        XCTAssertEqual(OctDay(day: 31).medium, "Sat 31 Oct")
    }

    func testTimeFormats() {
        XCTAssertEqual(TimeOfDay(hour: 19, minute: 30).label, "7:30 pm")
        XCTAssertEqual(TimeOfDay(hour: 23, minute: 0).pill, "11 pm")
        XCTAssertEqual(TimeOfDay(hour: 0, minute: 5).label, "12:05 am")
        XCTAssertEqual(TimeOfDay.compactList([TimeOfDay(hour: 19, minute: 30), TimeOfDay(hour: 19, minute: 0)]), "7, 7:30 pm")
        XCTAssertEqual(TimeOfDay.compactList([TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 19, minute: 0)]), "9 am, 7 pm")
    }

    func testBorrowDatesFlowIntoEveryLaterLabel() {
        XCTAssertEqual(state.borrowSummary, "18 Oct → 19 Oct · 1 day")
        state.selectBorrowDay(OctDay(day: 21))     // a new first tap starts a new range
        XCTAssertEqual(state.borrowSummary, "21 Oct · Same day")
        state.selectBorrowDay(OctDay(day: 23))     // a later day ends it
        XCTAssertEqual(state.borrowRange, "21–23 Oct 2026")
        XCTAssertEqual(state.borrowSummary, "21 Oct → 23 Oct · 2 days")
        XCTAssertEqual(state.pickUpDay, OctDay(day: 21))
        XCTAssertEqual(state.returnDay, OctDay(day: 23))
        XCTAssertEqual(state.borrowerDetail, "Pick up: Wed 21 Oct, 7:30 pm · Block A Security Desk")
        XCTAssertTrue(state.lenderDetail.contains("21–23 Oct 2026"))
    }

    func testUnavailableAndTooLongRangesAreRefused() {
        state.selectBorrowDay(OctDay(day: 16))     // Thomas is busy 15–17 Oct
        XCTAssertEqual(state.borrowRange, "18–19 Oct 2026")
        state.selectBorrowDay(OctDay(day: 30))     // after his availability
        XCTAssertEqual(state.borrowRange, "18–19 Oct 2026")
        state.selectBorrowDay(OctDay(day: 18))
        state.selectBorrowDay(OctDay(day: 27))     // 9 days: starts a new range instead
        XCTAssertEqual(state.borrowRange, "27 Oct 2026")
    }

    func testPickUpAndReturnDaysStayInsideTheRange() {
        state.selectBorrowDay(OctDay(day: 20))
        state.selectBorrowDay(OctDay(day: 24))
        state.choosePickUpDay(OctDay(day: 22))
        XCTAssertEqual(state.pickUpDay.day, 22)
        state.chooseReturnDay(OctDay(day: 21))     // before pick-up: ignored
        XCTAssertEqual(state.returnDay.day, 24)
        state.chooseReturnDay(OctDay(day: 23))
        XCTAssertEqual(state.returnLabel, "Fri 23 Oct · 10:30 am")
        state.choosePickUpDay(OctDay(day: 26))     // outside the range: ignored
        XCTAssertEqual(state.pickUpDay.day, 22)
    }

    func testOfferedTimesDriveThomasChoices() {
        state.addPickUpOffer(TimeOfDay(hour: 18, minute: 0))
        XCTAssertEqual(state.pickUpOfferText, "6, 7, 7:30 pm")
        state.choosePickUp(TimeOfDay(hour: 21, minute: 0))   // not offered: ignored
        XCTAssertNil(state.pickUpChoice)
        state.choosePickUp(TimeOfDay(hour: 18, minute: 0))
        XCTAssertEqual(state.pickUpLabel, "Sun 18 Oct · 6:00 pm")
        state.removePickUpOffer(TimeOfDay(hour: 18, minute: 0))
        XCTAssertNil(state.pickUpChoice, "removing the chosen time clears the choice")
        state.clearReturnOffers()
        XCTAssertFalse(state.canSendProposal)
        state.addReturnOffer(TimeOfDay(hour: 22, minute: 30))
        XCTAssertTrue(state.canSendProposal)
        XCTAssertEqual(state.returnOfferText, "10:30 pm")
    }

    func testSameDayReturnMustFollowPickUp() {
        state.selectBorrowDay(OctDay(day: 20))     // single-day borrow
        XCTAssertEqual(state.pickUpDay, state.returnDay)
        XCTAssertFalse(state.canOfferReturn(TimeOfDay(hour: 18, minute: 0)))
        XCTAssertTrue(state.canOfferReturn(TimeOfDay(hour: 21, minute: 0)))
    }

    func testScenarioReturnIsMondayMorning() {
        XCTAssertEqual(MockData.defaultReturnOffers.map(\.pill), ["9 am", "10 am", "10:30 am"])
        state.choosePickUp(Scenario.defaultPickUpTime)
        state.chooseReturn(Scenario.defaultReturnTime)
        XCTAssertEqual(state.returnLabel, "Mon 19 Oct · 10:30 am")
        XCTAssertEqual(MockData.chat(state)[1].text, "Sure, see you there! I’ll return it tomorrow by 10:30 am.")
        XCTAssertEqual(MockData.jamesReviews.last?.text, "Careful with my drill. I would lend the item again.")
    }

    func testMeetUpSpotFlowsIntoLabelsAndChat() {
        XCTAssertFalse(state.meetUpChosen)
        state.chooseMeetUpSpot(.blk12)
        XCTAssertTrue(state.meetUpChosen)
        XCTAssertTrue(state.borrowerDetail.hasSuffix("· Blk 12"))
        XCTAssertTrue(MockData.chat(state)[0].text.contains("Blk 12"))
    }

    func testRadiusFiltersSteamerResults() {
        state.setRadius(.current)
        XCTAssertEqual(state.steamerResults.map(\.id), ["steamer"])
        state.setRadius(.km5)
        XCTAssertEqual(state.steamerResults.map(\.id), ["steamer"], "the Xiaomi steamer is 16.8 km away")
        XCTAssertEqual(state.radius.phrase, "within 5 km")
    }

    func testPaymentMethodIsRemembered() {
        XCTAssertEqual(state.paymentMethod, .payNow)
        state.choosePaymentMethod(.applePay)
        state.depositPaid()
        XCTAssertEqual(state.paymentMethod, .applePay)
        state.reset()
        XCTAssertEqual(state.paymentMethod, .payNow)
    }

    func testRatingsKeepTheStarsTapped() {
        state.rateThomas(3)
        XCTAssertEqual(state.thomasCategoryStars.values.sorted(), [3, 3, 3, 3, 3])
        state.rateThomas(5, category: "Punctuality")
        XCTAssertEqual(state.thomasCategoryStars["Punctuality"], 5)
        XCTAssertEqual(state.jamesRatingOfThomas, 3)
    }

    // MARK: Roles

    func testRoleJumpsFlipCurrentUserWithBanner() {
        router.go(.s2_4)
        XCTAssertEqual(state.currentUser, .james)
        router.go(.s3_1)                          // 2.4 → 3.1
        XCTAssertEqual(state.currentUser, .thomas)
        XCTAssertEqual(state.roleBanner, "Now viewing as Thomas")
        router.go(.s4_14)                         // "Both" frames keep the current user
        XCTAssertEqual(state.currentUser, .thomas)
        router.go(.s8_5)
        XCTAssertEqual(state.currentUser, .thomas)
        router.go(.s5_2)
        XCTAssertEqual(state.currentUser, .james)
    }

    // MARK: Router

    func testSheetsPresentOverThePageAndHandleDismisses() {
        router.go(.s2_1)
        router.go(.s2_2)
        XCTAssertEqual(router.sheet, .s2_2)
        XCTAssertEqual(router.currentPage, .s2_1)
        router.dismissSheet()
        XCTAssertNil(router.sheet)
        XCTAssertEqual(router.visible, .s2_1)
    }

    func testLinkToAFrameAlreadyInTheStackPopsBack() {
        router.go(.s5_2)
        router.go(.s5_2b)
        router.go(.s5_2)                          // "Cancel payment"
        XCTAssertEqual(router.path, [.s5_2])
    }

    func testTabsResetToTheirRoots() {
        router.go(.s2_1)
        router.select(.lend)
        XCTAssertEqual(router.root, .s9_1)
        XCTAssertTrue(router.path.isEmpty)
        XCTAssertEqual(AppTab.borro.root, .s2_4)
        XCTAssertEqual(AppTab.you.root, .s8_9)
    }

    func testDemoJumpPreparesMatchingState() {
        router.jump(to: .s6_19)
        XCTAssertEqual(state.status, .onLoan)
        XCTAssertEqual(state.deposit, .held)
        XCTAssertTrue(state.dropOffSaved)
        router.jump(to: .s8_8)
        XCTAssertEqual(state.deposit, .refunded)
        router.jump(to: .s1_1)
        XCTAssertEqual(state.status, .pending)
        XCTAssertEqual(state.deposit, .unpaid)
    }

    func testResetRestoresLaunchState() {
        state.setStatus(.returned)
        state.depositPaid()
        state.addPhoto(.front, to: .returned)
        state.reset()
        XCTAssertEqual(state.status, .pending)
        XCTAssertEqual(state.deposit, .unpaid)
        XCTAssertFalse(state.photoSet(.returned).hasFront)
        XCTAssertEqual(state.currentUser, .james)
    }

    // MARK: Scenario data

    func testScenarioFacts() {
        XCTAssertEqual(MockData.james.credibility, 72)
        XCTAssertEqual(MockData.james.rating, "3.5")
        XCTAssertEqual(MockData.james.reviewCount, 45)
        XCTAssertEqual(MockData.thomas.rating, "5.0")
        XCTAssertEqual(MockData.thomas.reviewCount, 10)
        XCTAssertEqual(Scenario.reference, "BR-20481")
        XCTAssertEqual(Scenario.lenderCode, "6767")
        XCTAssertEqual(Scenario.borrowerCode, "8482")
        XCTAssertEqual(Scenario.depositAmount, "$10")
        XCTAssertEqual(Scenario.meetUpPlace, "Block A Security Desk")
        XCTAssertEqual(Screen.allCases.count, 128, "127 Figma frames plus the app-only Apple Pay sheet")
    }

    func testPayNowQRCodeIsGenerated() {
        XCTAssertNotNil(QRCodeView.make(Scenario.payNowQRPayload))
    }
}
