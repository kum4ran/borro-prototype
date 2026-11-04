import SwiftUI
import UIKit

// MARK: - Photo catalog
//
// Every bitmap in the prototype comes straight out of the Figma file.
// Files live in Borro/Resources/Photos/<key>.png.

struct BPhoto: Hashable {
    let key: String

    var image: UIImage? {
        if let img = UIImage(named: key) { return img }
        for ext in ["png", "jpg", "jpeg"] {
            if let url = Bundle.main.url(forResource: key, withExtension: ext) {
                return UIImage(contentsOfFile: url.path)
            }
            if let url = Bundle.main.url(forResource: key, withExtension: ext, subdirectory: "Photos") {
                return UIImage(contentsOfFile: url.path)
            }
        }
        return nil
    }
}

extension BPhoto {
    // Brand
    static let logo = BPhoto(key: "logo_borro")

    // People
    static let james   = BPhoto(key: "avatar_james")
    static let thomas  = BPhoto(key: "avatar_thomas")
    static let kumaran = BPhoto(key: "avatar_man1")
    static let matthew = BPhoto(key: "avatar_man2")
    static let lebron  = BPhoto(key: "avatar_man3")
    static let andrew  = BPhoto(key: "alt_3")
    static let sam     = BPhoto(key: "avatar_man5")
    static let dara    = BPhoto(key: "photo_cf751bc1de")
    static let jessica = BPhoto(key: "avatar_woman1")
    static let mei     = BPhoto(key: "avatar_woman2")
    static let niamh   = BPhoto(key: "alt_1")
    static let lea     = BPhoto(key: "avatar_woman4")

    // Items
    static let steamer        = BPhoto(key: "steamer_main")
    static let steamerTwo     = BPhoto(key: "list_photo5")
    static let steamerDesk    = BPhoto(key: "steamer_desk")
    static let steamerShirt   = BPhoto(key: "steamer_shirt3")
    static let steamerBooks   = BPhoto(key: "list_photo3")
    static let steamerProduct = BPhoto(key: "list_photo2")
    static let projector      = BPhoto(key: "item_projector")
    static let projectorDark  = BPhoto(key: "projector_2")
    static let projectorSide  = BPhoto(key: "projector_3")
    static let projectorScreen = BPhoto(key: "screen_1")
    static let jblSpeaker     = BPhoto(key: "speaker_concert")
    static let speakerDark    = BPhoto(key: "speaker_dark")
    static let speakerCyl     = BPhoto(key: "speaker_cyl")
    static let speakerDesk    = BPhoto(key: "speaker_desk2")
    static let camera         = BPhoto(key: "camera_1")
    static let football       = BPhoto(key: "football_1")
    static let bottle         = BPhoto(key: "bottle_green")

    // UI art
    static let payNow     = BPhoto(key: "paynow")
    static let lockScreen = BPhoto(key: "lockscreen")
    static let blackFrame = BPhoto(key: "black_frame")

    // Listing / damage / alternatives
    static let damage1 = BPhoto(key: "speaker_dark")
    static let damage2 = BPhoto(key: "projector_3")
    static let damageReview1 = BPhoto(key: "speaker_cyl")
    static let damageReview2 = BPhoto(key: "damage_review2")
    static let damageReview3 = BPhoto(key: "damage_review3")
    static let alt1 = BPhoto(key: "alt_1")
    static let alt2 = BPhoto(key: "alt_2")
    static let alt3 = BPhoto(key: "alt_3")
    static let listPhoto1 = BPhoto(key: "list_photo1")
    static let extra1 = BPhoto(key: "photo_7854425d76")
    static let extra2 = BPhoto(key: "photo_7f80fa37b5")
    static let extra3 = BPhoto(key: "photo_7ff1a7e325")
    static let extra4 = BPhoto(key: "photo_bab946ba63")
    static let extra5 = BPhoto(key: "photo_c8ecf538e8")
    static let listPhoto2 = BPhoto(key: "list_photo2")
    static let listPhoto3 = BPhoto(key: "list_photo3")
    static let listPhoto4 = BPhoto(key: "list_photo4")
}

// MARK: - Renderer

struct BImageView: View {
    var photo: BPhoto
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = BRadius.photo

    var body: some View {
        Group {
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ZStack {
                    BColor.surfaceAlt
                    Image(systemName: "photo")
                        .font(.system(size: 18))
                        .foregroundStyle(BColor.inkTertiary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// Circular avatar: real photo, with initials fallback.
struct BAvatarView: View {
    var photo: BPhoto?
    var initials: String = ""
    var size: CGFloat = 24

    var body: some View {
        Group {
            if let photo, photo.image != nil {
                BImageView(photo: photo, cornerRadius: size / 2)
            } else {
                ZStack {
                    BColor.brandSoft
                    Text(initials)
                        .font(BFont.semibold(size * 0.4))
                        .foregroundStyle(BColor.brand)
                }
                .clipShape(Circle())
            }
        }
        .frame(width: size, height: size)
    }
}

/// The blue Borro wordmark used in app bars.
struct BLogoMark: View {
    /// Figma logo lockup is 72 x 34 (wordmark 72 wide, centred).
    var width: CGFloat = 72

    init(width: CGFloat = 72) { self.width = width }

    /// Legacy callers that sized by height.
    init(height: CGFloat) { self.width = height * 4.25 }

    var body: some View {
        if let image = BPhoto.logo.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: width)
        } else {
            Text("Borro")
                .font(BFont.extraBold(width * 0.24))
                .foregroundStyle(BColor.brand)
        }
    }
}
