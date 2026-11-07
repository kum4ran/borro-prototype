import SwiftUI

/// Borrow Later date sheet (11.1, 11.2).
struct BorrowLaterSheet: View {
    let subtitle: String
    var onNext: (() -> Void)? = nil
    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(title: "Choose your borrowing dates", subtitle: subtitle) {
            VStack(spacing: Space.x16) {
                CalendarMonth()
                VStack(alignment: .leading, spacing: Space.x4) {
                    Text("18 Oct → 19 Oct · 1 day").font(.b(.s14)).foregroundStyle(Color.ink)
                    Text("Normal priority · Thomas must accept your request.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                }
                .panel(.successFill)
                PrimaryButton(title: "Send Request", identifier: "borrowLaterSendButton") {
                    if let onNext { onNext() } else { router.go(.s11_3) }
                }
            }
        }
    }
}
