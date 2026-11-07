import SwiftUI

/// Thomas's lender code with the countdown (6.1–6.9).
struct LenderCodeTop: View {
    @Environment(Router.self) private var router
    var body: some View {
        // CONFLICT: Figma shows 8482 on 6.3a, 6.3b, 6.5a and 6.6a. Handover screens always show the lender code.
        CodeCircle(code: Scenario.lenderCode, title: "My Lender Code") { router.go(.s6_2) }
    }
}

/// "Enter lender code" label with the info button that opens 6.13.
struct CodeEntryLabel: View {
    let title: String
    var infoTarget: Screen?
    @Environment(Router.self) private var router

    var body: some View {
        Button { if let infoTarget { router.go(infoTarget) } } label: {
            HStack(spacing: Space.x4) {
                Text(title).font(.b(.s13))
                IconView(icon: .info, size: Size.iconInfo)
            }
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity, minHeight: Size.hitTarget)
        }
        .buttonStyle(.plain)
        .padding(.vertical, -Space.x8)
        .accessibilityIdentifier("codeEntryInfo")
    }
}

/// Verified code boxes ("✓ Code verified · In-person handover").
struct VerifiedCodeTop: View {
    let title: String
    let code: String
    var infoTarget: Screen?

    var body: some View {
        VStack(spacing: Space.x8) {
            CodeEntryLabel(title: title, infoTarget: infoTarget)
            CodeBoxes(digits: code, style: .verified)
            Text("✓ Code verified · In-person handover").font(.r(.s10)).foregroundStyle(Color.inkSecondary)
        }
    }
}

/// James types the lender code (6.11, 6.12). Wrong code shows 6.12; 6767 opens 6.14.
struct LenderCodeEntryTop: View {
    let failed: Bool
    @State private var typed = ""
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: Space.x8) {
            CodeEntryLabel(title: "Enter lender code", infoTarget: .s6_13)
            CodeBoxes(digits: typed.isEmpty && failed ? "1234" : typed, style: failed && typed.isEmpty ? .error : .empty,
                      input: $typed,
                      onTapWhenLocked: appState.dropOffSaved ? nil : { router.go(.s6_13) })
            Text("Please enter the 4-digit code from your lender.").font(.r(.s10)).foregroundStyle(Color.inkSecondary)
            Text(failed ? "ⓘ Code doesn't match. Ask lender for the 4-digit code." : "ⓘ A code is required before you can confirm collection.")
                .font(.r(.s12)).foregroundStyle(Color.danger)
                .accessibilityIdentifier("codeMessage")
            if !failed {
                Button {
                    router.go(.s6_12)
                } label: {
                    Text("Simulate wrong code (1234)")
                        .font(.r(.s11))
                        .foregroundStyle(Color.inkSecondary)
                        .underline()
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    _ = appState.submitLenderCode(Scenario.lenderCode)
                    appState.markCollected()
                    router.go(.s6_14)
                } label: {
                    Text("Enter correct code (6767)")
                        .font(.s(.s12))
                        .foregroundStyle(Color.brand)
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: typed) { _, code in
            guard code.count == Scenario.codeLength else { return }
            if appState.submitLenderCode(code) {
                appState.markCollected()
                router.go(.s6_14)
            } else {
                typed = ""
                router.go(.s6_12)
            }
        }
    }
}

/// Thomas types the borrower code on 7.2; verified boxes once it matches.
struct BorrowerCodeEntryTop: View {
    @State private var typed = ""
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.returnCodeVerified {
            VerifiedCodeTop(title: "Enter borrower code", code: Scenario.borrowerCode)
        } else {
            VStack(spacing: Space.x8) {
                CodeEntryLabel(title: "Enter borrower code")
                CodeBoxes(digits: typed, style: .empty, input: $typed)
                Text("Ask James to show his return code.").font(.r(.s10)).foregroundStyle(Color.inkSecondary)
                Button {
                    _ = appState.submitBorrowerCode(Scenario.borrowerCode)
                } label: {
                    Text("Enter James's return code (4545)")
                        .font(.s(.s12))
                        .foregroundStyle(Color.brand)
                        .underline()
                }
                .buttonStyle(.plain)
            }
            .onChange(of: typed) { _, code in
                if code.count == Scenario.codeLength, !appState.submitBorrowerCode(code) { typed = "" }
            }
        }
    }
}
