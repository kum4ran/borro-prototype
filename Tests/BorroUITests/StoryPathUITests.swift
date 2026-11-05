import XCTest

/// Walks the whole story path, 1.1 to 8.9, using accessibility identifiers only.
final class StoryPathUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testFullStoryPath() throws {
        // 1 Discover
        expectScreen("1.1")
        tap("needItNowToggle"); expectScreen("1.2")
        tap("filterButton"); expectScreen("1.3")
        tap("filter.Location"); expectScreen("1.4")
        tap("locationSearchButton"); expectScreen("1.5")
        tap("listing.steamer"); expectScreen("2.1")

        // 2 Request
        tap("borrowNowButton"); expectScreen("2.2")
        tap("sendRequestButton"); expectScreen("2.3")
        tap("viewMyBorrowingButton"); expectScreen("2.4")
        expectLabel("steamerCard", contains: "Pending")

        // 3 Thomas decides (simulated jump)
        tap("steamerCard"); expectScreen("3.1")
        tap("pushNotification"); expectScreen("3.2")
        tap("request.james"); expectScreen("3.3")
        tap("acceptRequestButton"); expectScreen("3.7")
        tap("confirmAcceptButton"); expectScreen("3.8")
        tap("pushNotification"); expectScreen("3.9")

        // 4 Schedule
        tap("arrangeHandoverButton"); expectScreen("4.1")
        tap("pickUpRow"); expectScreen("4.2")
        tap("nextSetTimesButton"); expectScreen("4.3")
        tap("timesDoneButton"); expectScreen("4.4")
        tap("nextSetTimesButton"); expectScreen("4.5")
        tap("timesDoneButton"); expectScreen("4.6")
        tap("useLocationButton"); expectScreen("4.7")
        tap("sendProposalButton"); expectScreen("4.8")
        tap("waitingForThomasBanner"); expectScreen("4.11")
        tap("acceptProposalButton"); expectScreen("4.12")
        XCTAssertFalse(element("confirmTimesButton").isEnabled)
        tap("timePill.7:30 pm")
        tap("timePill.10:30 am")
        tap("confirmTimesButton"); expectScreen("4.14")

        // 5 Agreement and PayNow
        tap("viewFinalAgreementButton"); expectScreen("5.2")
        tap("payNowButton"); expectScreen("5.2a")
        tap("payWithPayNowButton"); expectScreen("5.2b")
        XCTAssertTrue(element("payNowQR").exists)
        tap("iHavePaidButton"); expectScreen("5.2c")
        expectScreen("5.2d", timeout: 6)
        tap("paymentContinueButton"); expectScreen("5.5")
        tap("submitAgreementButton"); expectScreen("5.6")
        tap("goToTimelineButton"); expectScreen("5.7")

        // 6 Handover: Thomas drops off
        tap("timelineActionButton"); expectScreen("6.1")
        XCTAssertEqual(element("codeDigits").label, "6767")
        tap("addPhotoButton"); expectScreen("6.3")
        tap("confirmUploadButton"); expectScreen("6.4")
        tap("confirmPhotosButton"); expectScreen("6.9")
        tap("confirmSubmissionButton"); expectScreen("6.10")
        tap("handOverButton"); expectScreen("6.10a")

        // James collects: wrong code first, then 6767
        tap("timelineActionButton"); expectScreen("6.11")
        tap("codeBoxes"); app.typeText("1234"); expectScreen("6.12")
        tap("codeBoxes"); app.typeText("6767"); expectScreen("6.14")
        tap("addPhotoButton"); expectScreen("6.14a")
        tap("confirmPhotosButton"); expectScreen("6.18")
        tap("confirmSubmissionButton"); expectScreen("6.19")
        tap("viewTimelineButton"); expectScreen("6.20")

        // 7 Return
        tap("timelineActionButton"); expectScreen("7.1")
        tap("confirmReturnDropOffButton"); expectScreen("7.2")
        tap("codeBoxes"); app.typeText("8482")
        tap("addPhotoButton"); expectScreen("7.2a")
        tap("confirmPhotosButton"); expectScreen("7.4")
        tap("confirmSubmissionButton"); expectScreen("7.5")
        tap("viewReturnStatusButton"); expectScreen("7.6")

        // 8 Reviews and refund
        tap("timelineActionButton"); expectScreen("8.2")
        app.buttons.matching(identifier: "star.5").firstMatch.tap(); expectScreen("8.3")
        tap("submitReviewButton"); expectScreen("8.4")
        tap("viewDepositRefundButton"); expectScreen("8.8")
        expectLabel("depositStatus", contains: "Refunded")
        tap("thomasPushBanner"); expectScreen("8.5")
        tap("pushNotification"); expectScreen("8.6")
        tap("submitReviewButton"); expectScreen("8.7")
        tap("backToMyLendingButton"); expectScreen("9.1")
        tap("tab.you"); expectScreen("8.9")
    }

    func testChosenTimesShowOnHandoverConfirmed() throws {
        app.terminate()
        app.launchArguments = ["-startScreen", "4.12"]
        app.launch()
        expectScreen("4.12")
        tap("timePill.7 pm")
        tap("timePill.9 am")
        tap("confirmTimesButton"); expectScreen("4.14")
        XCTAssertTrue(app.staticTexts["Sun 18 Oct · 7:00 pm"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Mon 19 Oct · 9:00 am"].exists)
    }

    func testChosenBorrowDatesShowOnRequestSent() throws {
        app.terminate()
        app.launchArguments = ["-startScreen", "2.2"]
        app.launch()
        expectScreen("2.2")
        tap("day.21")
        tap("day.23")
        expectLabel("borrowSummary", contains: "21 Oct → 23 Oct · 2 days")
        tap("sendRequestButton"); expectScreen("2.3")
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "21 → 23 Oct 2026")).firstMatch.exists)
    }

    func testApplePayPath() throws {
        app.terminate()
        app.launchArguments = ["-startScreen", "5.2"]
        app.launch()
        tap("applePayButton"); expectScreen("5.2f")
        tap("confirmApplePayButton"); expectScreen("5.2c")
        expectScreen("5.2d", timeout: 6)
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Apple Pay")).firstMatch.exists)
    }

    func testCodeCountdownTicks() throws {
        app.terminate()
        app.launchArguments = ["-startScreen", "6.1"]
        app.launch()
        let timer = element("codeTimer")
        XCTAssertTrue(timer.waitForExistence(timeout: 5))
        let first = timer.label
        sleep(2)
        XCTAssertNotEqual(timer.label, first)
    }

    // MARK: Helpers

    private func element(_ id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    private func tap(_ id: String, file: StaticString = #filePath, line: UInt = #line) {
        let e = element(id)
        XCTAssertTrue(e.waitForExistence(timeout: 5), "missing \(id)", file: file, line: line)
        if !e.isHittable { app.swipeUp() }
        e.tap()
    }

    private func expectLabel(_ id: String, contains text: String, file: StaticString = #filePath, line: UInt = #line) {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        let found = XCTNSPredicateExpectation(predicate: predicate, object: element(id))
        XCTAssertEqual(XCTWaiter().wait(for: [found], timeout: 5), .completed,
                       "\(id) label is \"\(element(id).label)\"", file: file, line: line)
    }

    private func expectScreen(_ code: String, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element("screen.\(code)").waitForExistence(timeout: timeout), "expected frame \(code)", file: file, line: line)
    }
}
