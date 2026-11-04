import SwiftUI

/// Hidden stakeholder menu (long-press the status bar): jump to any section or frame, or reset.
struct DemoMenu: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private static let sections: [(title: String, first: Screen)] = [
        ("1 · Discover", .s1_1), ("2 · Request", .s2_1), ("3 · Lender decides", .s3_1),
        ("4 · Schedule and chat", .s4_1), ("5 · Lending agreement", .s5_2), ("6 · Handover", .s6_1),
        ("7 · Return", .s7_1), ("8 · Reviews and refund", .s8_1), ("9 · My Lending, List an Item", .s9_1),
        ("10 · Damage and cancellation", .s10_1), ("11 · Other screens", .s11_1),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Sections") {
                    ForEach(Self.sections, id: \.first) { section in
                        Button(section.title) { open(section.first) }
                            .accessibilityIdentifier("demo.section.\(section.first.code)")
                    }
                }
                Section("All frames") {
                    ForEach(Screen.allCases) { screen in
                        Button(screen.frameName) { open(screen) }
                            .font(.r(.s14))
                            .accessibilityIdentifier("demo.frame.\(screen.code)")
                    }
                }
                Section {
                    Button("Reset demo", role: .destructive) {
                        appState.reset()
                        router.reset()
                        dismiss()
                    }
                    .accessibilityIdentifier("demo.reset")
                }
            }
            .navigationTitle("Demo menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }

    private func open(_ screen: Screen) {
        dismiss()
        router.jump(to: screen)
    }
}
