import SwiftUI

/// Figma frame "5.2e Both · Terms & Conditions" (node 925:193).
struct S5_2e_TermsConditionsView: View {
    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Terms & Conditions", subtitle: "Borro lending agreement · Garment Steamer")
        } content: {
            Text(TermsContent.intro).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            VStack(alignment: .leading, spacing: Space.x16) {
                ForEach(TermsContent.sections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: Space.x4) {
                        Text(section.title).font(.b(.s14)).foregroundStyle(Color.ink)
                        Text(section.body).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
                    }
                }
                Text(TermsContent.updated).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            .cardStyle(padding: Space.x16, shadow: false)
        }
    }
}

#Preview {
    PreviewHost(.s5_2e)
}
