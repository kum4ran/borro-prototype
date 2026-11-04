import Foundation

// MARK: - Generated catalog of the 13 Figma sections and their 122 artboards.
// Source: design/figma/nodes.json · regenerate with tools/gen_flow_catalog.py

struct FlowFrame: Identifiable, Hashable {
    var id: String { slug }
    let slug: String
    let name: String
    let index: Int
}

struct FlowSection: Identifiable, Hashable {
    var id: String { node }
    let node: String
    let title: String
    let number: String
    let flow: FlowID?
    let frames: [FlowFrame]
}

enum FlowCatalog {
    static let sections: [FlowSection] = [
        FlowSection(node: "703:124", title: "1 · Discover (James)", number: "1", flow: nil, frames: [
            FlowFrame(slug: "691-4139", name: "1.1 James · Home", index: 1),
            FlowFrame(slug: "691-4256", name: "1.2 James · Home · Need it Now on", index: 2),
            FlowFrame(slug: "691-4365", name: "1.3 James · Filter menu", index: 3),
            FlowFrame(slug: "691-4492", name: "1.4 James · Location map · 1 km", index: 4),
            FlowFrame(slug: "691-4657", name: "1.5 James · Results · steamer within 1 km", index: 5),
        ]),
        FlowSection(node: "703:125", title: "2 · Request (James)", number: "2", flow: .request, frames: [
            FlowFrame(slug: "691-4767", name: "2.1 James · Item details · Garment Steamer", index: 1),
            FlowFrame(slug: "691-4822", name: "2.2 James · Borrow request · Borrow Now", index: 2),
            FlowFrame(slug: "691-5008", name: "2.3 James · Request sent · waiting for Thomas", index: 3),
            FlowFrame(slug: "691-5063", name: "2.4 James · My Borrowing", index: 4),
        ]),
        FlowSection(node: "700:124", title: "3 · Lender decides (Thomas)", number: "3", flow: .lender, frames: [
            FlowFrame(slug: "691-5139", name: "3.1 Thomas · Push · new request", index: 1),
            FlowFrame(slug: "700-125", name: "3.2 Thomas · Borrow Requests", index: 2),
            FlowFrame(slug: "700-198", name: "3.3 Thomas · Borrow request expanded", index: 3),
            FlowFrame(slug: "691-5216", name: "3.4 Thomas · James public profile", index: 4),
            FlowFrame(slug: "691-5308", name: "3.6 Thomas · James all reviews", index: 5),
            FlowFrame(slug: "700-439", name: "3.7 Thomas · Accept James' request? (dialog)", index: 6),
            FlowFrame(slug: "700-520", name: "3.8 James · Push · request accepted", index: 7),
            FlowFrame(slug: "691-5405", name: "3.9 James · Request accepted", index: 8),
            FlowFrame(slug: "701-124", name: "3.5 Thomas · Credibility score info", index: 9),
        ]),
        FlowSection(node: "701:202", title: "4 · Schedule and chat", number: "4", flow: .schedule, frames: [
            FlowFrame(slug: "701-203", name: "4.1 James · Propose handover", index: 1),
            FlowFrame(slug: "701-284", name: "4.2 James · Pick-up dates (pop-up)", index: 2),
            FlowFrame(slug: "701-429", name: "4.3 James · Pick-up times (pop-up)", index: 3),
            FlowFrame(slug: "701-585", name: "4.4 James · Return dates (pop-up)", index: 4),
            FlowFrame(slug: "701-762", name: "4.5 James · Return times (pop-up)", index: 5),
            FlowFrame(slug: "701-951", name: "4.6 James · Pick on map", index: 6),
            FlowFrame(slug: "701-1059", name: "4.7 James · Times chosen", index: 7),
            FlowFrame(slug: "701-1177", name: "4.8 James · Proposal sent", index: 8),
            FlowFrame(slug: "691-5576", name: "4.9 James · Chat with Thomas", index: 9),
            FlowFrame(slug: "701-1267", name: "4.10 James · Chat attachment menu", index: 10),
            FlowFrame(slug: "701-1366", name: "4.11 Thomas · Review proposal", index: 11),
            FlowFrame(slug: "701-1464", name: "4.12 Thomas · Choose times (pop-up)", index: 12),
            FlowFrame(slug: "701-1626", name: "4.13 Thomas · Request changes (branch)", index: 13),
            FlowFrame(slug: "701-1718", name: "4.14 Both · Handover confirmed", index: 14),
        ]),
        FlowSection(node: "701:1806", title: "5 · Lending agreement", number: "5", flow: .agreement, frames: [
            FlowFrame(slug: "691-5698", name: "5.1 Thomas · Agreement sent", index: 1),
            FlowFrame(slug: "691-5763", name: "5.2 James · Final Agreement", index: 2),
            FlowFrame(slug: "691-5836", name: "5.3 James · Lender care note", index: 3),
            FlowFrame(slug: "691-5930", name: "5.4 James · Deposit info", index: 4),
            FlowFrame(slug: "691-6006", name: "5.5 James · Deposit paid", index: 5),
            FlowFrame(slug: "691-6074", name: "5.6 James · Agreement submitted", index: 6),
        ]),
        FlowSection(node: "703:126", title: "6 · Handover (codes + photos)", number: "6", flow: .handover, frames: [
            FlowFrame(slug: "691-6129", name: "6.1 Thomas · Drop-off · lender code", index: 1),
            FlowFrame(slug: "703-434", name: "6.2 Thomas · Lender code info (sheet)", index: 2),
            FlowFrame(slug: "703-765", name: "6.6 Thomas · Add additional photos", index: 3),
            FlowFrame(slug: "703-1074", name: "6.7 Thomas · Photo options (delete / upload / retake)", index: 4),
            FlowFrame(slug: "703-1403", name: "6.8 Thomas · Edit photo name (sheet)", index: 5),
            FlowFrame(slug: "703-1718", name: "6.9 Thomas · Ready to submit? (sheet)", index: 6),
            FlowFrame(slug: "703-2035", name: "6.10 Thomas · Drop-off saved · share code", index: 7),
            FlowFrame(slug: "691-6435", name: "6.11 James · Collection · enter lender code", index: 8),
            FlowFrame(slug: "703-2090", name: "6.12 James · Wrong code", index: 9),
            FlowFrame(slug: "703-2171", name: "6.13 James · Meet in person first (sheet)", index: 10),
            FlowFrame(slug: "703-2262", name: "6.14 James · Code verified", index: 11),
            FlowFrame(slug: "703-2342", name: "6.17 James · Missing photos (sheet)", index: 12),
            FlowFrame(slug: "703-2430", name: "6.15 James · Photo added", index: 13),
            FlowFrame(slug: "703-2512", name: "6.16 James · Photo options", index: 14),
            FlowFrame(slug: "703-2615", name: "6.18 James · Ready to submit? (sheet)", index: 15),
            FlowFrame(slug: "691-6511", name: "6.19 Both · Handover summary", index: 16),
            FlowFrame(slug: "691-6585", name: "6.20 Both · Timeline · ongoing", index: 17),
            FlowFrame(slug: "704-166", name: "6.3 Thomas · Name the photo (sheet)", index: 18),
            FlowFrame(slug: "704-484", name: "6.4 Thomas · Front photo added", index: 19),
            FlowFrame(slug: "704-792", name: "6.5 Thomas · Back photo (empty)", index: 20),
        ]),
        FlowSection(node: "735:178", title: "6b · Photo steps per pill 1 / 2 / 3 (all NEW)", number: "6b", flow: .handover, frames: [
            FlowFrame(slug: "736-170", name: "6.3a Thomas · Name the back photo (sheet)", index: 1),
            FlowFrame(slug: "736-486", name: "6.3b Thomas · Name the extra photo (sheet)", index: 2),
            FlowFrame(slug: "736-804", name: "6.5a Thomas · Back photo added", index: 3),
            FlowFrame(slug: "736-1115", name: "6.6a Thomas · Extra photo added", index: 4),
            FlowFrame(slug: "736-1432", name: "6.14a James · Front photo added", index: 5),
            FlowFrame(slug: "736-1533", name: "6.14b James · Back photo (empty)", index: 6),
            FlowFrame(slug: "736-1634", name: "6.14c James · Back photo added", index: 7),
            FlowFrame(slug: "736-1738", name: "6.14d James · Add additional photos", index: 8),
            FlowFrame(slug: "736-1844", name: "7.2a Thomas · Front photo added", index: 9),
            FlowFrame(slug: "736-1945", name: "7.2b Thomas · Back photo (empty)", index: 10),
            FlowFrame(slug: "736-2046", name: "7.2c Thomas · Back photo added", index: 11),
            FlowFrame(slug: "736-2150", name: "7.2d Thomas · Add additional photos", index: 12),
        ]),
        FlowSection(node: "739:185", title: "6c · Timeline stages (NEW)", number: "6c", flow: .handover, frames: [
            FlowFrame(slug: "739-225", name: "5.7 Both · Timeline · agreed", index: 1),
            FlowFrame(slug: "739-311", name: "6.10a Both · Timeline · meet-up", index: 2),
        ]),
        FlowSection(node: "703:2704", title: "7 · Return", number: "7", flow: .returnFlow, frames: [
            FlowFrame(slug: "691-6651", name: "7.1 James · Return code + after photos", index: 1),
            FlowFrame(slug: "703-2705", name: "7.2 Thomas · Enter borrower code", index: 2),
            FlowFrame(slug: "703-2785", name: "7.3 Thomas · Return photo added", index: 3),
            FlowFrame(slug: "703-2867", name: "7.4 Thomas · Ready to submit? (sheet)", index: 4),
            FlowFrame(slug: "691-6709", name: "7.5 Both · Return confirmed", index: 5),
            FlowFrame(slug: "703-2954", name: "7.6 Both · Timeline · refund processing", index: 6),
        ]),
        FlowSection(node: "703:3017", title: "8 · Reviews and refund", number: "8", flow: .reviews, frames: [
            FlowFrame(slug: "703-3018", name: "8.1 James · Push · rate Thomas", index: 1),
            FlowFrame(slug: "691-6828", name: "8.2 James · Rate Thomas", index: 2),
            FlowFrame(slug: "703-3041", name: "8.3 James · Rate Thomas · filled", index: 3),
            FlowFrame(slug: "691-6916", name: "8.4 James · Review submitted", index: 4),
            FlowFrame(slug: "703-3129", name: "8.5 Thomas · Push · rate James", index: 5),
            FlowFrame(slug: "691-6963", name: "8.6 Thomas · Rate James", index: 6),
            FlowFrame(slug: "703-3152", name: "8.7 Thomas · Review submitted", index: 7),
            FlowFrame(slug: "691-6764", name: "8.8 Both · Timeline · deposit refunded", index: 8),
            FlowFrame(slug: "691-7051", name: "8.9 James · Profile", index: 9),
        ]),
        FlowSection(node: "708:169", title: "9 · My Lending and List an Item (side branch, data not reconciled)", number: "9", flow: .lending, frames: [
            FlowFrame(slug: "708-170", name: "9.1 Thomas · My Lending · Active", index: 1),
            FlowFrame(slug: "708-275", name: "9.2 Thomas · My Lending · Sort / Filter", index: 2),
            FlowFrame(slug: "708-414", name: "9.3 Thomas · My Lending · Past loans", index: 3),
            FlowFrame(slug: "708-518", name: "9.4 Thomas · Past loans · Sort / Filter", index: 4),
            FlowFrame(slug: "708-648", name: "9.5 Thomas · Manage listing menu", index: 5),
            FlowFrame(slug: "708-775", name: "9.6 Thomas · Paused listing", index: 6),
            FlowFrame(slug: "708-889", name: "9.7 Thomas · Delete confirmation", index: 7),
            FlowFrame(slug: "708-1002", name: "9.8 Thomas · List an Item · Step 1 photos", index: 8),
            FlowFrame(slug: "708-1065", name: "9.9 Thomas · Step 2 details", index: 9),
            FlowFrame(slug: "708-1135", name: "9.10 Thomas · Step 3 pick-up", index: 10),
            FlowFrame(slug: "708-1214", name: "9.11 Thomas · Step 4 availability", index: 11),
            FlowFrame(slug: "708-1363", name: "9.12 Thomas · Step 5 period", index: 12),
            FlowFrame(slug: "708-1421", name: "9.13 Thomas · Step 6 deposit", index: 13),
            FlowFrame(slug: "708-1510", name: "9.14 Thomas · Step 7 care", index: 14),
            FlowFrame(slug: "708-1574", name: "9.15 Thomas · Step 8 terms", index: 15),
            FlowFrame(slug: "708-1634", name: "9.16 Thomas · Listing preview", index: 16),
            FlowFrame(slug: "708-1691", name: "9.17 Thomas · Steamer is live", index: 17),
        ]),
        FlowSection(node: "708:1741", title: "10 · Damage and cancellation (edge cases, not in scenario)", number: "10", flow: .damage, frames: [
            FlowFrame(slug: "708-1742", name: "10.1 Thomas · Report damage · incomplete", index: 1),
            FlowFrame(slug: "708-1842", name: "10.2 Thomas · Report damage · filled", index: 2),
            FlowFrame(slug: "708-1942", name: "10.3 Thomas · Damage tracker · submitted", index: 3),
            FlowFrame(slug: "708-2017", name: "10.4 Thomas · Damage tracker · evaluating", index: 4),
            FlowFrame(slug: "708-2089", name: "10.5 Thomas · Damage tracker · verifying", index: 5),
            FlowFrame(slug: "708-2160", name: "10.6 Both · Timeline · damage", index: 6),
            FlowFrame(slug: "708-2234", name: "10.7 Both · Timeline · repair", index: 7),
            FlowFrame(slug: "708-2298", name: "10.8 Both · Post-Borro review · damage", index: 8),
            FlowFrame(slug: "708-2371", name: "10.9 Both · Repair balance paid", index: 9),
            FlowFrame(slug: "708-2421", name: "10.10 James · Push · borrowing cancelled", index: 10),
            FlowFrame(slug: "708-2443", name: "10.11 James · Borrowing cancelled · alternatives", index: 11),
            FlowFrame(slug: "708-2513", name: "10.12 James · Nearby alternatives", index: 12),
            FlowFrame(slug: "708-2598", name: "10.13 James · Find new lender", index: 13),
        ]),
        FlowSection(node: "708:2690", title: "11 · Other screens (Borrow Later, Wishlist, AI chat)", number: "11", flow: .other, frames: [
            FlowFrame(slug: "708-2691", name: "11.1 James · Item details · Borrow Later", index: 1),
            FlowFrame(slug: "708-2877", name: "11.2 James · Borrow Later · pick dates", index: 2),
            FlowFrame(slug: "708-2984", name: "11.3 James · Borrow Later · request sent", index: 3),
            FlowFrame(slug: "708-3039", name: "11.4 James · Wishlist", index: 4),
            FlowFrame(slug: "708-3121", name: "11.5 James · Ask Borro (AI chat)", index: 5),
        ]),
    ]

    static let totalFrames = 122

    static var frameSlugs: [String] { sections.flatMap { $0.frames.map(\.slug) } }

    static func frames(for flow: FlowID) -> [FlowFrame] {
        sections.filter { $0.flow == flow }.flatMap(\.frames)
    }

    static func section(for frameSlug: String) -> FlowSection? {
        sections.first { s in s.frames.contains { $0.slug == frameSlug } }
    }
}
