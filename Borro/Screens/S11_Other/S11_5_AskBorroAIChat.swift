import SwiftUI

/// Figma frame "11.5 James · Ask Borro (AI chat)" (node 708:3121).
/// Scripted replies only; no model calls.
struct S11_5_AskBorroAIChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(id: "q0", text: MockData.askBorroQuestion, time: "7:45 pm", mine: true, read: true),
    ]
    @State private var draft = ""

    var body: some View {
        ScreenScaffold {
            BackAppBar(title: "Borro · Ask me")
        } content: {
            ForEach(messages) { message in
                if message.mine {
                    ChatBubble(message: message)
                } else {
                    BorroReply(text: message.text)
                }
            }
            if messages.count == 1 {
                BorroReply(text: MockData.askBorroAnswer)
                HStack(spacing: Space.x12) {
                    PhotoView(photo: .steamerDesk).frame(width: Size.guideThumb.width, height: Size.guideThumb.height)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.r8))
                    VStack(alignment: .leading, spacing: Space.x4) {
                        Text("Garment Steamer – Quick-use guide").font(.b(.s13)).foregroundStyle(Color.ink)
                        Text("▶ YouTube · 2:14").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                    }
                }
                .cardStyle()
            }
            Text("Always follow your lender’s care instructions.").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
        } actions: {
            HStack(spacing: Space.x10) {
                IconView(icon: .plus, size: Size.iconSmall).foregroundStyle(Color.brand)
                TextField("Ask Borro..", text: $draft)
                    .font(.r(.s14))
                    .submitLabel(.send)
                    .onSubmit(send)
                    .accessibilityIdentifier("askBorroField")
                IconButton(icon: .send, size: Size.iconSmall, tint: .brand, label: "Send", action: send)
            }
            .padding(.leading, Space.x14)
            .background(Color.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.stroke, lineWidth: Size.stroke))
        }
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        if messages.count == 1 {
            messages.append(ChatMessage(id: "a0", text: MockData.askBorroAnswer, time: "", mine: false))
        }
        messages.append(ChatMessage(id: "q\(messages.count)", text: text, time: "7:46 pm", mine: true, read: true))
        let lower = text.lowercased()
        let reply = MockData.askBorroReplies.first { $0.keywords.contains(where: lower.contains) }?.reply ?? MockData.askBorroFallback
        messages.append(ChatMessage(id: "a\(messages.count)", text: reply, time: "", mine: false))
        draft = ""
    }
}

/// Borro’s answer card with the blue "Borro" label.
private struct BorroReply: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: Space.x8) {
            Text("Borro").font(.b(.s15)).foregroundStyle(Color.brand)
            Text(text).font(.r(.s14)).foregroundStyle(Color.ink)
        }
        .cardStyle(shadow: false)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PreviewHost(.s11_5)
}
