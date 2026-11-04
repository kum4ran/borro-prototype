import SwiftUI

/// Figma frame "10.8 Both · Post-Borro review · damage" (node 708:2298).
struct S10_8_PostBorroReviewDamageView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Post-Borro Review", subtitle: "Garment Steamer · Damage case", backTo: .s10_7)
        } content: {
            InfoBanner(icon: .check, title: "Outcome", message: "Accidental – both parties agree on compensation.")
            HStack(spacing: Space.x12) {
                PhotoView(photo: .steamerMain).frame(width: Size.thumbSquare, height: Size.thumbSquare)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("Before").font(.b(.s14)).foregroundStyle(Color.ink)
                    Text("Working and in mint condition").font(.r(.s13)).foregroundStyle(Color.ink)
                    Text("No dents on steamer case").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
                }
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x8) {
                Text("After · Dent on steamer body").font(.b(.s14)).foregroundStyle(Color.ink)
                HStack(spacing: Space.x8) {
                    ForEach([Photo.steamerShirt, .listPhoto4, .listPhoto2], id: \.self) { photo in
                        PhotoView(photo: photo).frame(height: Size.recordPhoto).clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                    }
                }
                Text("2 photos · 1 video · 0:18").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle()
            VStack(spacing: Space.x10) {
                Text("Repair quote").font(.b(.s15)).foregroundStyle(Color.ink).frame(maxWidth: .infinity, alignment: .leading)
                KeyValueRow(key: "Repair", value: MockData.repairQuote)
                KeyValueRow(key: "Deposit applied", value: MockData.depositApplied)
                KeyValueRow(key: "Balance to pay", value: MockData.repairBalance)
            }
            .cardStyle()
        } actions: {
            PrimaryButton(title: "Pay Now – \(MockData.repairBalance)", identifier: "payRepairButton") { router.go(.s10_9) }
            SecondaryButton(title: "Chat with Thomas") { router.go(.s4_9) }
        }
    }
}

#Preview {
    PreviewHost(.s10_8)
}
