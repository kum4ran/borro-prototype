import SwiftUI

/// Body of James's public profile (3.4, and under the tooltip on 3.5).
struct JamesPublicProfile: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var user: User {
        if router.path.contains(.s2_1) {
            return appState.selectedListing.owner
        }
        return MockData.james
    }

    var body: some View {
        ScreenScaffold {
            BigBackAppBar(title: "Public profile", backTo: .s3_3)
        } content: {
            ProfileHeader(user: user)
            PrimaryButton(title: "Chat Now") { router.go(.s4_9) }
            VStack(alignment: .leading, spacing: Space.x16) {
                CredibilityGauge(score: user.credibility > 0 ? user.credibility : 86, label: user.credibilityLabel.isEmpty ? "High" : user.credibilityLabel) { router.go(.s3_5) }
                CredibilityBreakdown(factors: MockData.jamesCredibility)
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x8) {
                HStack {
                    Text("Overall rating").font(.r(.s14)).foregroundStyle(Color.inkSecondary)
                    Spacer()
                    Text("★ \(user.rating.isEmpty ? "5.0" : user.rating) · \(user.reviewCount > 0 ? "\(user.reviewCount) reviews" : "10 reviews")").font(.s(.s14)).foregroundStyle(Color.ink)
                }
                if let review = MockData.jamesReviews.first {
                    Text("“\(review.text)”").font(.r(.s13)).foregroundStyle(Color.ink)
                    Text("\(review.author) · \(review.date)").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                }
                LinkButton(title: "See all reviews →") { router.go(.s3_6) }
                    .accessibilityIdentifier("seeAllReviews")
            }
            .cardStyle()
        }
    }
}

/// App bar with the 25 pt title used on profile frames.
struct BigBackAppBar: View {
    let title: String
    var backTo: Screen?
    @Environment(Router.self) private var router

    var body: some View {
        HStack(spacing: Space.x12) {
            IconButton(icon: .chevronLeft, label: "Back") {
                if router.path.count > 1 { router.back() } else if let backTo { router.go(backTo) } else { router.back() }
            }
            .padding(.leading, -Space.x12)
            .padding(.trailing, -Space.x10)
            .accessibilityIdentifier("backButton")
            Text(title).font(.b(.s25)).foregroundStyle(Color.ink).accessibilityAddTraits(.isHeader)
            Spacer()
        }
        .padding(.horizontal, Space.gutter)
        .frame(minHeight: Size.appBar)
    }
}
