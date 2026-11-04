import SwiftUI

/// Rating form shared by 8.2, 8.3 (James rates Thomas) and 8.6 (Thomas rates James).
struct RatePage: View {
    @Environment(AppState.self) private var appState
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
                Avatar(photo: person.photo, size: Size.avatarLarge)
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("Rate \(person.name)").font(.b(.s21)).foregroundStyle(Color.ink)
                    Text("Garment Steamer").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                    Text(appState.borrowRange).font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                }
            }
            VStack(spacing: Space.x4) {
                ForEach(AppState.reviewCategories, id: \.self) { category in
                    HStack {
                        Text("\(category)*").font(.s(.s12)).foregroundStyle(Color.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(Size.titleMinScale)
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
            ForEach(1...Review.maxStars, id: \.self) { i in
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
        .accessibilityValue("\(value) of \(Review.maxStars)")
    }
}

/// "Thank you for your review!" (8.4, 8.7).
struct ReviewSubmittedPage<Extra: View>: View {
    @Environment(AppState.self) private var appState
    let person: String
    /// The stars given per category, shown back as the saved review.
    var stars: [String: Int] = [:]
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
                if !stars.isEmpty {
                    let average = Double(stars.values.reduce(0, +)) / Double(stars.count)
                    HStack(spacing: Space.x6) {
                        StarRow(value: Int(average.rounded())) { _ in }
                            .allowsHitTesting(false)
                            .padding(.vertical, -Space.x10)
                        Text(String(format: "%.1f", average)).font(.b(.s14)).foregroundStyle(Color.ink)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(String(format: "You rated %@ %.1f out of 5", person, average))
                    .accessibilityIdentifier("savedRating")
                }
                Text("Your review has been saved · \(appState.returnDay.withYear)").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle(shadow: false)
            extra()
        } actions: {
            PrimaryButton(title: action, identifier: actionID, action: perform)
        }
    }
}
