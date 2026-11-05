import Foundation

/// Fixed scenario facts (brief section 4). Never use `Date()`; the story runs on these.
enum Scenario {
    static let reference = "BR-20481"
    static let codeLength = 4
    static let lenderCode = "6767"      // Thomas shows it at drop-off, James types it on 6.11
    static let borrowerCode = "8482"    // James shows it at return, Thomas types it on 7.2
    static let codeRefreshSeconds = 45

    static let depositAmount = "$10"
    static let depositAmountSGD = "$10.00 SGD"
    static let depositAmountExact = "$10.00"
    static let payNowQRPayload = "BORRO-BR-20481"
    static let payNowExpiry = "04:59"
    static let paymentProcessingSeconds: Double = 2

    static let meetUpPlace = MeetingSpot.blockA.name   // CONFLICT: scenario says "reception"; Figma and brief say Block A Security Desk.
    static let area = "Bencoolen St"

    // Default schedule: borrow Sun 18 to Mon 19 Oct 2026, pick-up 7:30 pm. James can change all of it.
    static let defaultBorrowStart = OctDay(day: 18)
    static let defaultBorrowEnd = OctDay(day: 19)
    /// Today is Sun 18 Oct; Thomas's steamer is free until 27 Oct (9.11) and busy 15–17 Oct.
    static let borrowableDays = 18...27
    static let maxBorrowDays = 7
    static let requestDay = OctDay(day: 18)
    static let defaultPickUpTime = TimeOfDay(hour: 19, minute: 30)

    // Scenario text and Figma (updated 4 Nov 2026) agree: return Monday 19 Oct, 10:30 am.
    static let defaultReturnTime = TimeOfDay(hour: 10, minute: 30)
    static let returnTime = defaultReturnTime.label

    static let reviewPushTime = "11:05"
    static let statusBarTime = "10:00"
}
