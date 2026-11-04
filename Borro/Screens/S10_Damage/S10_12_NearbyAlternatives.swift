import SwiftUI

/// Figma frame "10.12 James · Nearby alternatives" (node 708:2513).
struct S10_12_NearbyAlternativesView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Nearby alternatives", subtitle: "Garment Steamer · 18–19 Oct", backTo: .s10_11)
        } content: {
            Text("Here are 3 nearby alternatives. No need to start over.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            ForEach(MockData.alternatives, id: \.user.id) { AlternativeCard(user: $0.user, distance: $0.distance) }
        } actions: {
            PrimaryButton(title: "Find a New Lender", identifier: "findNewLenderButton") { router.go(.s10_13) }
        }
    }
}

#Preview {
    PreviewHost(.s10_12)
}
