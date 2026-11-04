import SwiftUI

/// Final Agreement page: 5.2 before paying, 5.5 after. Also the page under 5.2a, 5.3 and 5.4.
struct FinalAgreementPage: View {
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState

    var body: some View {
        let paid = appState.deposit != .unpaid
        ScreenScaffold {
            BackAppBar(title: "Final Agreement", subtitle: "James & Thomas · \(appState.borrowRange)", backTo: .s4_9) {
                LinkButton(title: "Suggest changes") { router.go(.s4_9) }
            }
        } content: {
            AgreementItemCard(dates: appState.agreementDates, place: appState.meetUpPlace)
            TapArea(accessibilityLabel: "Safety deposit \(Scenario.depositAmount), deposit info") { router.go(.s5_4) } label: {
                HStack(spacing: Space.x8) {
                    Text("Safety Deposit: \(Scenario.depositAmount)").font(.b(.s18)).foregroundStyle(Color.ink)
                    IconView(icon: .info, size: Size.iconInfo).foregroundStyle(Color.ink)
                }
            }
            .accessibilityIdentifier("depositInfoRow")
            if paid {
                DepositPaidPanel(paid: true, method: appState.paymentMethod)
            } else {
                HStack(spacing: Space.x8) {
                    Button { router.go(.s5_2a) } label: {
                        PhotoView(photo: .payNowLogo, contentMode: .fit)
                            .frame(height: Size.payLogo)
                            .frame(maxWidth: .infinity, minHeight: Size.payButton)
                            .overlay(Capsule().strokeBorder(Color.brand, lineWidth: Size.buttonStroke))
                            .contentShape(Capsule())
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityLabel("Pay with PayNow")
                    .accessibilityIdentifier("payNowButton")
                    // Not wired in Figma; the app adds an Apple Pay path (5.2f, app only).
                    Button { router.go(.s5_2f) } label: {
                        HStack(spacing: Space.x2) {
                            Image(systemName: "apple.logo").font(.b(.s18))
                            Text("Pay").font(.inter(.semibold, .s20))
                        }
                        .foregroundStyle(Color.inkBlack)
                        .frame(maxWidth: .infinity, minHeight: Size.payButton)
                        .overlay(Capsule().strokeBorder(Color.brand, lineWidth: Size.buttonStroke))
                        .contentShape(Capsule())
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityLabel("Pay with Apple Pay")
                    .accessibilityIdentifier("applePayButton")
                }
                Text("Selecting a payment method authorises your \(Scenario.depositAmount) deposit.")
                    .font(.r(.s11)).foregroundStyle(Color.inkSecondary)
            }
            TapArea(accessibilityLabel: "Instructions from lender") { router.go(.s5_3) } label: {
                HStack {
                    Text("Instructions From Lender").font(.b(.s11)).foregroundStyle(Color.inkBlack)
                    Spacer()
                    IconView(icon: .externalLink, size: Size.iconSmall).foregroundStyle(Color.ink)
                }
                .cardStyle(shadow: false)
            }
            .accessibilityIdentifier("lenderInstructionsCard")
            TermsCard { router.go(.s5_2e) }
            CheckboxRow(text: "I agree to the Terms & Conditions and the lender's care instructions.",
                        checked: appState.agreedToTerms) { appState.toggleAgreedToTerms() }
        } actions: {
            PrimaryButton(title: "Submit Agreement", enabled: appState.canSubmitAgreement,
                          identifier: "submitAgreementButton") { router.go(.s5_6) }
            SecondaryButton(title: "Cancel") { router.go(.s5_2) }
        }
    }
}


