import SwiftUI

/// Figma frame "9.17 Thomas · Steamer is live" (node 708:1691).
struct S9_17_SteamerIsLiveView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BigBackAppBar(title: "You’re all set!")
        } content: {
            IconView(icon: .shieldCheck, size: Size.seal / 2).foregroundStyle(Color.brand).frame(maxWidth: .infinity)
            VStack(spacing: Space.x8) {
                Text("Your steamer is live!").font(.b(.s24)).foregroundStyle(Color.ink)
                Text("A little less buying. A little more sharing.").font(.r(.s14)).foregroundStyle(Color.inkSecondary)
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: Space.x8) {
                PhotoView(photo: .listPhoto4)
                    .frame(height: Size.listingHero)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
                Text(MockData.steamer.title).font(.b(.s15)).foregroundStyle(Color.ink)
                HStack {
                    Text("Listing status").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                    Spacer()
                    Text("Active").font(.b(.s15)).foregroundStyle(Color.success)
                }
                Text("\(Scenario.area) · Available 13–27 Oct").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle()
        } actions: {
            PrimaryButton(title: "View My Listings", identifier: "viewMyListingsButton") { router.go(.s9_1) }
        }
    }
}

#Preview {
    PreviewHost(.s9_17)
}
