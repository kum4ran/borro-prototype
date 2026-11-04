import SwiftUI

/// Figma frame "10.3 James · Damage tracker · submitted" (node 708:1942).
struct S10_3_DamageTrackerSubmittedView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Damage report status", subtitle: "Garment Steamer · Thomas", backTo: .s10_6)
        } content: {
            InfoBanner(icon: .info, title: "Your report is being reviewed",
                       message: "We’ve shared your evidence with Thomas. We’ll keep both of you updated.")
            HStack(spacing: Space.x12) {
                PhotoView(photo: .steamerMain).frame(width: Size.thumbSquare, height: Size.thumbSquare)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                VStack(alignment: .leading, spacing: Space.x4) {
                    Text("Dent on steamer body").font(.b(.s15)).foregroundStyle(Color.ink)
                    Text("Reported 19 Oct 2026 · \(Scenario.reference)").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    Chip(text: "Left side · Dent", fill: .successFill, ink: .success)
                }
            }
            .cardStyle()
            VStack(alignment: .leading, spacing: Space.x14) {
                TapArea(accessibilityLabel: "Report submitted, in progress") { router.go(.s10_4) } label: {
                    HStack(spacing: Space.x12) {
                        Text("1").font(.b(.s13)).foregroundStyle(Color.surface)
                            .frame(width: Size.checkpoint, height: Size.checkpoint).background(Color.brand, in: Circle())
                        VStack(alignment: .leading, spacing: Space.x2) {
                            Text("Report submitted").font(.s(.s14)).foregroundStyle(Color.ink)
                            Text("In progress · We’re on it").font(.r(.s11)).foregroundStyle(Color.brand)
                        }
                        Spacer()
                    }
                }
                .accessibilityIdentifier("checkpoint.1")
                ForEach(Array(["Evaluating damage", "Verifying information", "Outcome"].enumerated()), id: \.offset) { i, title in
                    HStack(spacing: Space.x12) {
                        Text("\(i + 2)").font(.b(.s13)).foregroundStyle(Color.inkSecondary)
                            .frame(width: Size.checkpoint, height: Size.checkpoint).background(Color.track, in: Circle())
                        Text(title).font(.s(.s14)).foregroundStyle(Color.inkSecondary)
                    }
                }
            }
            .cardStyle()
            InfoBanner(icon: .clock, title: "Next update expected by 21 Oct",
                       message: "You can continue chatting with Thomas while we review the records.")
        } actions: {
            PrimaryButton(title: "Chat with Thomas") { router.go(.s4_9) }
        }
    }
}

#Preview {
    PreviewHost(.s10_3)
}
