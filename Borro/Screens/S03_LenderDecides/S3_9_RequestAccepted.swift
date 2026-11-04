import SwiftUI

/// Figma frame "3.9 James · Request accepted" (node 691:5405).
struct S3_9_RequestAcceptedView: View {
    @Environment(Router.self) private var router
    private let request = MockData.request

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Request Accepted", subtitle: "Borrow Now · Lender approval")
        } content: {
            ResultSeal(icon: .check, fill: .successFill, tint: .brand)
            VStack(spacing: Space.x8) {
                Text("Approved by Thomas").font(.b(.s24)).foregroundStyle(Color.ink)
                Text("Next, agree on a pickup time and meeting place together.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            RequestSummaryCard(request: request)
        } actions: {
            PrimaryButton(title: "Arrange handover", identifier: "arrangeHandoverButton") { router.go(.s4_1) }
            SecondaryButton(title: "View My Borrowing") { router.go(.s2_4) }
        }
    }
}

/// Photo, title, urgency chip and the four request rows (2.3, 3.9).
struct RequestSummaryCard: View {
    let request: BorrowRequest

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x10) {
            PhotoView(photo: .steamerMain)
                .frame(height: Size.cardPhoto)
                .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
            Text(request.listing.title).font(.b(.s19)).foregroundStyle(Color.ink)
            Chip(text: "URGENT - Borrow Now", fill: .brand, ink: .surface)
            DotRow(label: "Borrower", value: request.borrower.name)
            DotRow(label: "Lender", value: request.lender.name)
            DotRow(label: "Requested dates", value: "18 → 19 Oct 2026")
            DotRow(label: "Duration", value: "1 day")
        }
        .cardStyle()
    }
}

#Preview {
    PreviewHost(.s3_9)
}
