import SwiftUI

/// Figma frame "10.6 Both · Timeline · damage" (node 708:2160).
struct S10_6_TimelineDamageView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Timeline", subtitle: "Garment Steamer · \(Scenario.reference)")
        } content: {
            StageBar(current: AppState.TimelineStage.lending.rawValue)
            HStack {
                Text("Garment Steamer").font(.b(.s20)).foregroundStyle(Color.ink)
                Spacer()
                Chip(text: "Lending", fill: .brandMist, ink: .brand)
            }
            VStack(alignment: .leading, spacing: Space.x4) {
                Text("Damage report in progress").font(.b(.s13)).foregroundStyle(Color.pendingInk)
                Text("Report submitted ✓ · Evaluating damage · Next update by 21 Oct").font(.r(.s12)).foregroundStyle(Color.inkSecondary)
            }
            .panel(.pendingFill)
            DamageBeforeAfter()
            SecondaryButton(title: "Track damage report") { router.go(.s10_3) }
            HStack(spacing: Space.x8) {
                IconView(icon: .shieldCheck, size: Size.iconSmall).foregroundStyle(Color.brand)
                Text("Deposit · \(Scenario.depositAmount) · Held safely").font(.b(.s13)).foregroundStyle(Color.ink)
            }
            .panel(.successFill)
        } actions: {
            PrimaryButton(title: "Ready to Return") { router.go(.s7_1) }
        }
    }
}

/// "Condition Before → After" photo grid (10.6).
struct DamageBeforeAfter: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Space.x8) {
            Text("Condition Before → After").font(.b(.s15)).foregroundStyle(Color.ink)
            pair(.steamerMain, .steamerDesk)
            Text("Before · Working and in mint condition · 18 Oct").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            pair(.steamerShirt, .listPhoto4)
            Text("After · Dent on steamer body · 19 Oct").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
        }
    }

    private func pair(_ a: Photo, _ b: Photo) -> some View {
        HStack(spacing: Space.x8) {
            PhotoView(photo: a).frame(height: Size.beforeAfterPhoto).clipShape(RoundedRectangle(cornerRadius: Radius.r8))
            PhotoView(photo: b).frame(height: Size.beforeAfterPhoto).clipShape(RoundedRectangle(cornerRadius: Radius.r8))
        }
    }
}

#Preview {
    PreviewHost(.s10_6)
}
