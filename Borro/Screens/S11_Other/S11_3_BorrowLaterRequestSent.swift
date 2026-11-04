import SwiftUI

/// Figma frame "11.3 James · Borrow Later · request sent" (node 708:2984).
struct S11_3_BorrowLaterRequestSentView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BigBackAppBar(title: "Request sent")
        } content: {
            ResultSeal(icon: .check, fill: .successMint, tint: .brand).padding(.top, Space.x24)
            VStack(spacing: Space.x12) {
                Text("Good things are on the way.").font(.b(.s24)).foregroundStyle(Color.ink)
                Text("Request sent – waiting for Thomas to accept").font(.r(.s14)).foregroundStyle(Color.ink)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            HStack(spacing: Space.x12) {
                PhotoView(photo: .steamerDesk).frame(width: Size.thumbSquare, height: Size.thumbSquare)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                VStack(alignment: .leading, spacing: Space.x4) {
                    Text("Garment Steamer").font(.b(.s15)).foregroundStyle(Color.ink)
                    Text(MockData.borrowLaterDates).font(.r(.s12)).foregroundStyle(Color.ink)
                    Chip(text: "Pending acceptance")
                }
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("No deposit charged yet").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("We’ll let you know when your lender accepts. Then you can arrange the handover together.")
                    .font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        } actions: {
            PrimaryButton(title: "My Borrowing") { router.go(.s2_4) }
        }
    }
}

#Preview {
    PreviewHost(.s11_3)
}
