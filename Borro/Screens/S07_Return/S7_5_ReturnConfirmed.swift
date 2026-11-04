import SwiftUI

/// Figma frame "7.5 Both · Return confirmed" (node 691:6709).
struct S7_5_ReturnConfirmedView: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Return · Lender", subtitle: Scenario.meetUpPlace)
        } content: {
            IconView(icon: .check, size: Size.sealIcon)
                .foregroundStyle(Color.brand)
                .frame(width: Size.returnSeal, height: Size.returnSeal)
                .overlay(Circle().strokeBorder(Color.brand, lineWidth: Size.buttonStroke))
                .frame(maxWidth: .infinity)
            VStack(spacing: Space.x8) {
                Text("Return confirmed").font(.b(.s22)).foregroundStyle(Color.ink)
                Text("Both sides’ return records are saved.").font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .leading, spacing: Space.x10) {
                PhotoView(photo: .steamerMain)
                    .frame(height: Size.returnPhoto)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.photo))
                KeyValueRow(key: "Condition photos", value: "Front ✓ · Back ✓")
                KeyValueRow(key: "Time", value: "19 Oct · \(appState.returnTime)")
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Return record saved").font(.b(.s13)).foregroundStyle(Color.ink)
                Text("Your \(Scenario.depositAmount) deposit will be refunded automatically.").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.successFill)
        } actions: {
            PrimaryButton(title: "View return status", identifier: "viewReturnStatusButton") { router.go(.s7_6) }
        }
    }
}

#Preview {
    PreviewHost(.s7_5)
}
