import SwiftUI

/// Figma frame "7.1 James · Return code + after photos" (node 691:6651).
/// CONFLICT: Figma shows 6767 here; the return code is the borrower code 8482.
struct S7_1_ReturnCodeAfterPhotosView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Return handover", subtitle: appState.meetUpPlace)
        } content: {
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Garment Steamer").font(.b(.s14)).foregroundStyle(Color.ink)
                Text("James · Borrower shows code to Thomas").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            CodeCircle(code: Scenario.borrowerCode, title: "My Return Code")
            InfoBanner(icon: .info, title: "Meet in person first",
                       message: "Show this fresh return code to Thomas only when you meet in person. Thomas enters it on his phone to confirm the return.")
            Text("Photograph it as you leave it.").font(.b(.s16)).foregroundStyle(Color.ink)
            HStack(spacing: Space.x8) {
                afterPhoto("FRONT · ✓ Added")
                afterPhoto("BACK · ✓ Added")
            }
            Text("＋ ADDITIONAL · Optional").font(.r(.s11)).foregroundStyle(Color.ink)
                .cardStyle(padding: Space.x10, shadow: false)
            Text("Return · \(appState.returnDay.withYear) · \(appState.returnTime) · \(PhotoRules.requirementLine)")
                .font(.r(.s10)).foregroundStyle(Color.inkSecondary)
        } actions: {
            PrimaryButton(title: "Confirm Return Drop-off", identifier: "confirmReturnDropOffButton") { router.go(.s7_2) }
            SecondaryButton(title: "Report Damage", tint: .danger) { router.go(.s10_1) }
        }
    }

    private func afterPhoto(_ caption: String) -> some View {
        VStack(alignment: .leading, spacing: Space.x4) {
            PhotoView(photo: .steamerShirt)
                .frame(height: Size.photoThumb)
                .clipShape(RoundedRectangle(cornerRadius: Radius.r8))
            Text(caption).font(.b(.s10)).foregroundStyle(Color.ink)
        }
    }
}

#Preview {
    PreviewHost(.s7_1)
}
