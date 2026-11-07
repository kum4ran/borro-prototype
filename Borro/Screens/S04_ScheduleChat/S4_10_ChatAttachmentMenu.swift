import SwiftUI

/// Figma frame "4.10 James · Chat attachment menu" (node 701:1267). Sheet over 4.9.
struct S4_10_ChatAttachmentMenuView: View {
    @Environment(Router.self) private var router

    var body: some View {
        SheetContainer(title: "Add an attachment") {
            HStack {
                ForEach([(Icon.iconUpload, "Photo"), (.play, "Video"), (.iconCamera, "Camera"), (.location, "Location")], id: \.1) { item in
                    Button {
                        router.dismissSheet()
                        if item.1 == "Photo" || item.1 == "Camera" {
                            router.go(.s6_3)
                        } else if item.1 == "Location" {
                            router.go(.s4_6)
                        }
                    } label: {
                        VStack(spacing: Space.x8) {
                            IconView(icon: item.0, size: Size.icon)
                                .foregroundStyle(Color.success)
                                .frame(width: Size.attachmentTile, height: Size.attachmentTile)
                                .background(Color.successFill, in: RoundedRectangle(cornerRadius: Radius.card))
                            Text(item.1).font(.r(.s12)).foregroundStyle(Color.ink)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}

#Preview {
    PreviewHost(.s4_10)
}
