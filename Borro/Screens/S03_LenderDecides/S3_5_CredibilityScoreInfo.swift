import SwiftUI

/// Figma frame "3.5 Thomas · Credibility score info" (node 701:124). Tooltip over the profile.
struct S3_5_CredibilityScoreInfoView: View {
    @Environment(Router.self) private var router
    private let james = MockData.james

    var body: some View {
        JamesPublicProfile()
            .overlay(alignment: .top) {
                VStack(alignment: .leading, spacing: Space.x10) {
                    Text("How credibility is calculated").font(.b(.s16))
                    Text("Your score reflects successful transactions, on-time returns, item condition, communication, identity verification and cancellation history.")
                        .font(.r(.s14))
                    Text("Stars are reviewers’ average rating — not the same as your credibility score.")
                        .font(.r(.s14))
                    Text("\(james.credibility)/100 · \(james.credibilityLabel)").font(.b(.s13)).foregroundStyle(Color.tooltipMint)
                }
                .foregroundStyle(Color.surface)
                .padding(Space.x18)
                .background(Color.inkDeep, in: RoundedRectangle(cornerRadius: Radius.card))
                .padding(.horizontal, Space.gutter)
                .padding(.top, Size.tooltipTop)
                .onTapGesture { router.go(.s3_4) }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isButton)
                .accessibilityIdentifier("credibilityTooltip")
            }
    }
}

#Preview {
    PreviewHost(.s3_5)
}
