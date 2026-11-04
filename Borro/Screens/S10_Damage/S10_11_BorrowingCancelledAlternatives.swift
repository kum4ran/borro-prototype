import SwiftUI

/// Figma frame "10.11 James · Borrowing cancelled · alternatives" (node 708:2443).
struct S10_11_BorrowingCancelledAlternativesView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Borrowing cancelled", subtitle: "My Borrowing · Thomas")
        } content: {
            Text("Here are 3 nearby alternatives").font(.b(.s18)).foregroundStyle(Color.ink)
            Text("Your interview is tomorrow morning. These lenders can help tonight.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            AlternativeCard(user: MockData.priya, distance: "350 m")
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Sorry, your borrowing was cancelled.").font(.b(.s13)).foregroundStyle(Color.danger)
                Text("Thomas cancelled: unavailable due to personal circumstances.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.dangerFill)
            HStack(spacing: Space.x12) {
                PhotoView(photo: .steamerDesk).frame(width: Size.thumbSquare, height: Size.thumbSquare)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                VStack(alignment: .leading, spacing: Space.x4) {
                    Text("Garment Steamer").font(.b(.s14)).foregroundStyle(Color.ink)
                    Text("Thomas · \(Scenario.meetUpPlace)").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                    Chip(text: "Cancelled", fill: .track, ink: .inkSecondary)
                }
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Your deposit is on its way back").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("Your \(Scenario.depositAmount) deposit will be returned within 1 working day.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        } actions: {
            PrimaryButton(title: "See 3 nearby alternatives", identifier: "seeAlternativesButton") { router.go(.s10_12) }
        }
    }
}

#Preview {
    PreviewHost(.s10_11)
}
