import SwiftUI

/// Figma frame "4.9 James · Chat with Thomas" (node 691:5576).
struct S4_9_ChatWithThomasView: View {
    @Environment(Router.self) private var router

    var body: some View {
        ChatPage(onPlus: { router.go(.s4_10) })
    }
}

/// The chat thread shared by 4.9 and the page under 4.10.
struct ChatPage: View {
    var onPlus: () -> Void = {}
    @Environment(Router.self) private var router
    @Environment(AppState.self) private var appState
    private var chatPartner: User { appState.selectedListing.owner }

    var body: some View {
        ScreenScaffold(contentSpacing: Space.x12) {
            BackAppBar(title: chatPartner.name, subtitle: "★ \(chatPartner.rating) · \(chatPartner.reviewCount) reviews", backTo: .s4_14)
        } content: {
            Text("18 OCTOBER 2026").font(.m(.s11)).foregroundStyle(Color.inkSecondary).frame(maxWidth: .infinity)
            ForEach(MockData.chat(appState) + appState.customChatMessages) { ChatBubble(message: $0) }
            AgreementMessageCard { router.go(.s5_2) }
            HStack(spacing: Space.x8) {
                ForEach(["On my way", "Thanks", "See you soon"], id: \.self) { reply in
                    Button {
                        appState.sendChatMessage(reply, mine: true)
                    } label: {
                        Chip(text: reply, fill: .successFill, ink: .success, font: .s(.s11))
                    }
                    .buttonStyle(.plain)
                }
            }
            HStack(spacing: Space.x10) {
                Spacer()
                Chip(text: "Ask Borro", fill: .brand, ink: .surface, font: .b(.s13))
                Button { router.go(.s11_5) } label: {
                    BorroAppIcon()
                        .frame(width: Size.fab, height: Size.fab)
                        .background(Color.surface, in: Circle())
                        .overlay(Circle().strokeBorder(Color.brand, lineWidth: Size.mapDotStroke))
                }
                .buttonStyle(PressStyle())
                .accessibilityLabel("Ask Borro")
                .accessibilityIdentifier("askBorroButton")
            }
        } actions: {
            ChatComposer(placeholder: "Message \(chatPartner.name)…", onPlus: onPlus, onSend: { text in
                appState.sendChatMessage(text, mine: true)
            })
        }
    }
}

#Preview {
    PreviewHost(.s4_9)
}
