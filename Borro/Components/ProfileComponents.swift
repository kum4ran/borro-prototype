import SwiftUI

/// Lock-screen notification mock (3.1, 3.8, 8.1, 8.5, 10.10). Tapping anywhere follows the Figma link.
struct PushNotificationScreen: View {
    let date: String
    var time = Scenario.statusBarTime
    let title: String
    let message: String
    let meta: String
    var footer = "Tap to respond"
    let action: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            PhotoView(photo: .lockScreen).ignoresSafeArea()
            VStack(alignment: .leading, spacing: Space.x18) {
                IconView(icon: .lockKeyhole, size: Size.lockIcon).foregroundStyle(Color.surface)
                VStack(spacing: Space.x4) {
                    Text(date).font(.r(.s19))
                    Text(time).font(.b(.s76))
                }
                .foregroundStyle(Color.surface)
                .frame(maxWidth: .infinity)
                Button(action: action) {
                    VStack(alignment: .leading, spacing: Space.x12) {
                        HStack(spacing: Space.x10) {
                            BorroAppIcon()
                            Text("BORRO").font(.b(.s13)).foregroundStyle(Color.ink)
                            Spacer()
                            Text("now").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                        }
                        Text(title).font(.b(.s16)).foregroundStyle(Color.ink)
                        Text(message).font(.r(.s14)).foregroundStyle(Color.ink)
                        Text(meta).font(.b(.s13)).foregroundStyle(Color.brand)
                    }
                    .multilineTextAlignment(.leading)
                    .padding(Space.x16)
                    .background(Color.surface.opacity(Opacity.pushCard), in: RoundedRectangle(cornerRadius: Radius.r22))
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
                .accessibilityLabel("Borro notification: \(title)")
                .accessibilityIdentifier("pushNotification")
                Text(footer).font(.r(.s12)).foregroundStyle(Color.surface).frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Space.x18)
            .padding(.top, Space.x24)
        }
    }
}

/// Avatar, name, age line, verified chip (profile headers on 3.4–3.6, 8.9).
struct ProfileHeader: View {
    let user: User
    var name: String?

    var body: some View {
        HStack(alignment: .top, spacing: Space.x14) {
            Avatar(photo: user.photo, size: Size.avatarProfile)
            VStack(alignment: .leading, spacing: Space.x5) {
                Text(name ?? user.name).font(.b(.s23)).foregroundStyle(Color.ink)
                Text(user.ageAndCity).font(.r(.s14)).foregroundStyle(Color.inkSecondary)
                Chip(text: "✓ Identity verified", fill: .successFill, ink: .success)
            }
        }
    }
}

/// Half-ring gauge with the score in the middle.
struct CredibilityGauge: View {
    let score: Int
    let label: String
    var onInfo: (() -> Void)?

    var body: some View {
        VStack(spacing: Space.x2) {
            ZStack(alignment: .bottom) {
                HalfRing().stroke(Color.stroke, style: StrokeStyle(lineWidth: Size.gaugeStroke, lineCap: .round))
                HalfRing().trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(Color.brand, style: StrokeStyle(lineWidth: Size.gaugeStroke, lineCap: .round))
                Text("\(score)/100").font(.b(.s25)).foregroundStyle(Color.ink)
            }
            .frame(width: Size.gaugeWidth, height: Size.gaugeWidth / 2)
            Button { onInfo?() } label: {
                HStack(spacing: Space.x4) {
                    Text(label).font(.b(.s13))
                    IconView(icon: .info, size: Size.iconInfo)
                }
                .foregroundStyle(Color.brand)
                .frame(minHeight: Size.hitTarget)
            }
            .buttonStyle(.plain)
            .padding(.vertical, -Space.x10)
            .accessibilityLabel("\(score) out of 100, \(label). How credibility is calculated")
            .accessibilityIdentifier("credibilityScore")
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HalfRing: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: CGPoint(x: rect.midX, y: rect.maxY), radius: rect.width / 2,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        return p
    }
}

/// "Credibility breakdown": label, progress bar, value.
struct CredibilityBreakdown: View {
    let factors: [CredibilityFactor]

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x10) {
            Text("Credibility breakdown").font(.b(.s14)).foregroundStyle(Color.ink)
            ForEach(factors) { factor in
                HStack(spacing: Space.x8) {
                    Text(factor.label).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                        .frame(width: Size.factorLabel, alignment: .leading)
                    GeometryReader { proxy in
                        Capsule().fill(Color.track)
                            .overlay(alignment: .leading) {
                                Capsule().fill(Color.brand).frame(width: proxy.size.width * CGFloat(factor.score) / 100)
                            }
                    }
                    .frame(height: Space.x5)
                    Text("\(factor.score)").font(.b(.s11)).foregroundStyle(Color.ink)
                        .frame(width: Size.factorValue, alignment: .trailing)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

/// One review: author, gold stars, text, date.
struct ReviewRow: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x4) {
            HStack {
                Text(review.author).font(.b(.s14)).foregroundStyle(Color.inkBlack)
                Spacer()
                Text(review.starString).font(.r(.s15)).foregroundStyle(Color.pendingInk)
                    .accessibilityLabel("\(review.stars) out of 5 stars")
            }
            Text(review.text).font(.r(.s13)).foregroundStyle(Color.ink)
            Text(review.date).font(.r(.s11)).foregroundStyle(Color.inkSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Requester card on Borrow Requests (3.2, 3.7 background).
struct RequestCard: View {
    let requester: User
    let dates: String
    var urgent = true
    var onOpen: (() -> Void)?
    var onAccept: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Space.x10) {
            HStack(spacing: Space.x10) {
                Avatar(photo: requester.photo, size: Size.avatarMedium)
                VStack(alignment: .leading, spacing: Space.x2) {
                    Text("\(requester.name) ✓").font(.b(.s15)).foregroundStyle(Color.ink)
                    Text("\(requester.credibility)/100 · \(requester.credibilityLabel)").font(.r(.s11)).foregroundStyle(Color.inkSecondary)
                }
            }
            Button { onOpen?() } label: {
                (Text(requester.name).font(.b(.s15)) + Text(" wants to borrow Garment Steamer").font(.r(.s15)))
                    .foregroundStyle(Color.ink)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("request.\(requester.id)")
            Text(dates).font(.r(.s13)).foregroundStyle(Color.inkSecondary)
            if urgent { Chip(text: "⚡ URGENT – Borrow Now") }
            HStack(spacing: Space.x16) {
                PrimaryButton(title: "Accept") { onAccept?() }
                SecondaryButton(title: "Reject", tint: .danger) {}
            }
        }
        .cardStyle()
    }
}

/// The ring mark from the Borro logo, cropped square like the Figma "Borro app icon".
struct BorroAppIcon: View {
    var body: some View {
        PhotoView(photo: .logo, contentMode: .fit)
            .frame(width: Size.appIcon * Size.logoAspect, height: Size.appIcon)
            .frame(width: Size.appIcon, height: Size.appIcon, alignment: .trailing)
            .clipped()
    }
}
