import SwiftUI

/// Figma frame "3.6 Thomas · James all reviews" (node 691:5308).
struct S3_6_JamesAllReviewsView: View {
    private let james = MockData.james

    var body: some View {
        ScreenScaffold {
            BigBackAppBar(title: "James’ Reviews", backTo: .s3_4)
        } content: {
            ProfileHeader(user: james)
            VStack(alignment: .leading, spacing: Space.x10) {
                Text("\(james.credibility)/100 · \(james.credibilityLabel)").font(.b(.s14)).foregroundStyle(Color.ink)
                CredibilityBreakdown(factors: MockData.jamesCredibility)
            }
            .cardStyle()
            HStack(alignment: .firstTextBaseline) {
                SectionTitle(text: "Detailed reviews")
                Spacer()
                Text("★ \(james.rating) (\(james.reviewCount) reviews)").font(.b(.s13)).foregroundStyle(Color.inkBlack)
            }
            ForEach(MockData.jamesReviews) { review in
                ReviewRow(review: review).cardStyle()
            }
        }
    }
}

#Preview {
    PreviewHost(.s3_6)
}
