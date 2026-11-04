import SwiftUI

/// Frame layout for List an Item steps 1–8: step header, heading, body, Continue.
struct ListingStepPage<Content: View>: View {
    let step: Int
    let caption: String
    let heading: String
    var subheading: String?
    var backTo: Screen?
    var action = "Continue"
    let next: Screen
    @ViewBuilder var content: () -> Content

    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            ListingStepHeader(step: step, caption: caption, backTo: backTo)
        } content: {
            Text(heading).font(.b(.s24)).foregroundStyle(Color.ink).accessibilityAddTraits(.isHeader)
            if let subheading {
                Text(subheading).font(.r(.s14)).foregroundStyle(Color.inkSecondary)
            }
            content()
        } actions: {
            PrimaryButton(title: action, identifier: "listingContinueButton") { router.go(next) }
        }
    }
}
