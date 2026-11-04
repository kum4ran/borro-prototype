import SwiftUI

/// Figma frame "2.1 James · Item details · Garment Steamer" (node 691:4767).
struct S2_1_ItemDetailsGarmentSteamerView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Item description", subtitle: "Need it Now · 120 m away", backTo: .s1_5)
        } content: {
            ItemDetailsBody()
        } actions: {
            HStack(spacing: Space.x12) {
                PrimaryButton(title: "Borrow Now", identifier: "borrowNowButton") { router.go(.s2_2) }
                SecondaryButton(title: "Borrow Later") { router.go(.s11_2) }
            }
        }
    }
}

/// Content shared by 2.1 and 11.1.
struct ItemDetailsBody: View {
    @Environment(AppState.self) private var appState
    private let listing = MockData.steamer
    private let lender = MockData.thomas

    var body: some View {
        PhotoView(photo: .steamerMain)
            .frame(height: Size.detailPhoto)
            .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
        Text("● ○ ○ · 1 / 3").font(.r(.s11)).foregroundStyle(Color.brand)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Photo 1 of 3")
        HStack(alignment: .top) {
            Text(listing.title).font(.b(.s22)).foregroundStyle(Color.ink)
            Spacer()
            HeartToggle(liked: appState.isLiked(listing), size: Size.icon) { appState.toggleLike(listing) }
        }
        Text(MockData.steamerDescription).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
        VStack(alignment: .leading, spacing: Space.x8) {
            HStack(spacing: Space.x10) {
                Avatar(photo: lender.photo, size: Size.avatarMedium)
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("\(lender.name) ✓").font(.b(.s15)).foregroundStyle(Color.brand)
                    Text("\(lender.credibility)/100 · \(lender.credibilityLabel)").font(.r(.s11)).foregroundStyle(Color.ink)
                }
            }
            Text("Lender approval required · No instant booking").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
        }
        .cardStyle()
        VStack(alignment: .leading, spacing: Space.x4) {
            Text("Pickup · \(Scenario.meetUpPlace)").font(.b(.s14)).foregroundStyle(Color.ink)
            Text("120 m away · Bencoolen").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
        }
        .cardStyle(padding: Space.x10)
        VStack(alignment: .leading, spacing: Space.x8) {
            Text("Availability · October 2026").font(.b(.s14)).foregroundStyle(Color.ink)
            HStack(spacing: Space.x8) {
                Text("15–17 Oct · Busy").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                    .panel(.track, padding: Space.x8, radius: Radius.r8)
                // Free range follows the dates James can actually pick on 2.2.
                Text("\(Scenario.borrowableDays.lowerBound)–\(Scenario.borrowableDays.upperBound) Oct · Free").font(.r(.s12)).foregroundStyle(Color.brand)
                    .panel(.successFill, padding: Space.x8, radius: Radius.r8)
            }
            .frame(minHeight: Size.hitTarget)
        }
        .cardStyle(padding: Space.x10)
        Chip(text: "Deposit: \(Scenario.depositAmount)", fill: .successFill, ink: .success, font: .b(.s16))
    }
}

#Preview {
    PreviewHost(.s2_1)
}
