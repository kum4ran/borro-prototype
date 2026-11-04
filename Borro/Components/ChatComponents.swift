import SwiftUI

struct ChatMessage: Identifiable, Hashable {
    let id: String
    let text: String
    let time: String
    let mine: Bool
    var read = false
}

/// Chat bubble: white on the left for the other person, mint on the right for James.
struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.mine { Spacer(minLength: Space.x40) }
            VStack(alignment: .leading, spacing: Space.x4) {
                Text(message.text).font(.r(.s14)).foregroundStyle(Color.ink)
                Text(message.time + (message.read ? " ✓✓" : "")).font(.r(.s10)).foregroundStyle(Color.inkSecondary)
            }
            .padding(Space.x12)
            .frame(maxWidth: Size.bubbleMaxWidth, alignment: .leading)
            .background(message.mine ? Color.successFill : Color.surface, in: RoundedRectangle(cornerRadius: Radius.r16))
            if !message.mine { Spacer(minLength: Space.x40) }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Agreement card posted in the chat, with "Open Agreement".
struct AgreementMessageCard: View {
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x12) {
            HStack(spacing: Space.x10) {
                IconView(icon: .fileCheck2, size: Size.icon).foregroundStyle(Color.brand)
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("Final Agreement").font(.b(.s14)).foregroundStyle(Color.ink)
                    Text("Garment Steamer · Deposit \(Scenario.depositAmount)").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                }
            }
            SecondaryButton(title: "Open Agreement", identifier: "openAgreementButton", action: onOpen)
        }
        .cardStyle()
    }
}

/// Message composer pill ("Message Thomas…") with plus and send icons.
struct ChatComposer: View {
    let placeholder: String
    let onPlus: () -> Void

    var body: some View {
        HStack(spacing: Space.x10) {
            IconButton(icon: .plus, size: Size.iconSmall, tint: .inkSecondary, label: "Add attachment", action: onPlus)
                .accessibilityIdentifier("addAttachmentButton")
            Text(placeholder).font(.r(.s14)).foregroundStyle(Color.inkSecondary)
            Spacer()
            IconView(icon: .send, size: Size.iconSmall).foregroundStyle(Color.inkSecondary)
        }
        .padding(.horizontal, Space.x6)
        .padding(.trailing, Space.x10)
        .background(Color.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.stroke, lineWidth: Size.stroke))
    }
}
