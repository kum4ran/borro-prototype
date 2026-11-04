import SwiftUI

/// Rating form shared by 8.2, 8.3 (James rates Thomas) and 8.6 (Thomas rates James).
struct RatePage: View {
    let person: User
    let comment: String?
    let stars: [String: Int]
    let complete: Bool
    let onStar: (Int, String) -> Void
    let onSubmit: () -> Void

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Rate \(person.name)", subtitle: "A little feedback goes a long way")
        } content: {
            HStack(spacing: Space.x14) {
                Avatar(photo: person.photo, size: Size.avatarProfile - Space.x6)
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("Rate \(person.name)").font(.b(.s21)).foregroundStyle(Color.ink)
                    Text("Garment Steamer").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                    Text(Scenario.borrowDatesShort).font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                }
            }
            VStack(spacing: Space.x4) {
                ForEach(AppState.reviewCategories, id: \.self) { category in
                    HStack {
                        Text("\(category)*").font(.s(.s12)).foregroundStyle(Color.ink)
                        Spacer()
                        StarRow(value: stars[category] ?? 0) { onStar($0, category) }
                            .accessibilityLabel(category)
                    }
                }
            }
            Text("* Required").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            VStack(alignment: .leading, spacing: Space.x8) {
                Text("Comment (optional)").font(.b(.s13)).foregroundStyle(Color.ink)
                Text(comment ?? "Share your experience…")
                    .font(.r(.s14))
                    .foregroundStyle(comment == nil ? Color.inkSecondary : Color.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Space.x12)
                    .background(Color.surface, in: RoundedRectangle(cornerRadius: Radius.photo))
                    .overlay(RoundedRectangle(cornerRadius: Radius.photo).strokeBorder(Color.stroke, lineWidth: Size.stroke))
            }
            Text("Your ratings update \(person.name)'s credibility score.").font(.r(.s12)).foregroundStyle(Color.brand)
        } actions: {
            if complete {
                PrimaryButton(title: "Submit Review", identifier: "submitReviewButton", action: onSubmit)
            } else {
                MutedButton(title: "Submit Review") {}
            }
        }
    }
}

/// Five tappable stars: gold when filled, outline when not.
struct StarRow: View {
    let value: Int
    let onTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...5, id: \.self) { i in
                Button { onTap(i) } label: {
                    IconView(icon: .star, size: Size.starSize, filled: i <= value)
                        .foregroundStyle(i <= value ? Color.amber : Color.inkSecondary)
                        .frame(width: Size.starHit, height: Size.hitTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(i) star\(i == 1 ? "" : "s")")
                .accessibilityIdentifier("star.\(i)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityValue("\(value) of 5")
    }
}

/// "Thank you for your review!" (8.4, 8.7).
struct ReviewSubmittedPage<Extra: View>: View {
    let person: String
    let action: String
    let actionID: String
    let perform: () -> Void
    @ViewBuilder var extra: () -> Extra

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Review submitted", subtitle: "A little feedback goes a long way")
        } content: {
            ResultSeal(icon: .check, fill: .successMint, tint: .brand)
                .padding(.top, Space.x24)
            VStack(spacing: Space.x8) {
                Text("Thank you for your review!").font(.b(.s22)).foregroundStyle(Color.ink)
                Text("Your feedback helps neighbours borrow with confidence.").font(.r(.s14)).foregroundStyle(Color.inkSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: Space.x6) {
                Text("\(person) · Garment Steamer").font(.b(.s15)).foregroundStyle(Color.ink)
                Text("Your review has been saved · 19 Oct 2026").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle(shadow: false)
            extra()
        } actions: {
            PrimaryButton(title: action, identifier: actionID, action: perform)
        }
    }
}
