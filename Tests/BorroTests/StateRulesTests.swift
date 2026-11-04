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
        XCTAssertEqual(state.lenderDetail, "With James · Due Mon 19 Oct, \(Scenario.returnTimeCaps)")
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
        state.choosePickUp(MockData.pickUpOptions[1])
        XCTAssertFalse(state.bothTimesChosen)
        state.chooseReturn(MockData.returnOptions[1])
        XCTAssertTrue(state.bothTimesChosen)
        XCTAssertEqual(state.timesButtonLabel, "Confirm times")
        XCTAssertEqual(state.pickUpLabel, "Sun 18 Oct · 7:30 pm")
        XCTAssertEqual(state.returnLabel, "Mon 19 Oct · \(Scenario.returnTime)")
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
        XCTAssertEqual(Screen.allCases.count, 127)
    }

    func testPayNowQRCodeIsGenerated() {
        XCTAssertNotNil(QRCodeView.make(Scenario.payNowQRPayload))
    }
}
