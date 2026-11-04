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

    static let meetUpPlace = "Block A Security Desk"   // CONFLICT: scenario says "reception"; Figma and brief say Block A Security Desk.
    static let area = "Bencoolen St"
    static let borrowDates = "18 Oct to 19 Oct 2026"
    static let borrowDatesShort = "18–19 Oct 2026"
    static let pickUp = "Sun 18 Oct · 7:30 pm"
    static let pickUpTime = "7:30 pm"
    static let pickUpLong = "Sunday 18 Oct 2026, 7:30 pm"

    // CONFLICT: Figma shows 10:00 am on 5.2, the status strings and the Borro times default.
    // The scenario says Monday 19 Oct, 11:00 pm. Team has not decided. Change it here, in one line.
    static let returnTime = "11:00 pm"
    static let returnTimeCaps = "11:00 PM"
    static let returnPill = "11 pm"
    static let returnTime24 = "23"
    static let returnShort = "Mon 19 Oct · \(returnTime)"
    static let returnLong = "Monday 19 Oct 2026, \(returnTime)"

    static let reviewPushDate = "Monday 19 October"
    static let reviewPushTime = "11:05"
    static let statusBarTime = "10:00"

    static let radiusKm = "1 km"
}
