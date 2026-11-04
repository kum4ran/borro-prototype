import SwiftUI
import UIKit

/// Bitmaps exported from the Figma file, bundled under Resources/Photos.
/// File names are the old export names; the case names say what each one shows.
enum Photo: String, CaseIterable, Hashable {
    case logo = "logo_borro"

    // People
    case james = "avatar_james"
    case thomas = "avatar_thomas"
    case kumaran = "photo_7f80fa37b5"
    case matthew = "photo_cf751bc1de"
    case jessica = "avatar_woman1"
    case lebron = "avatar_man3"
    case mei = "avatar_woman2"
    case andrew = "avatar_man5"
    case manOne = "avatar_man1"
    case manTwo = "avatar_man2"
    case womanFour = "avatar_woman4"
    case personAlt = "alt_3"

    // Items
    case steamerMain = "steamer_main"
    case steamerDesk = "steamer_desk"
    case steamerShirt = "steamer_shirt3"
    case steamerTravel = "photo_7854425d76"
    case listPhoto1 = "list_photo1"
    case listPhoto2 = "list_photo2"
    case listPhoto3 = "list_photo3"
    case listPhoto4 = "list_photo4"
    case listPhoto5 = "list_photo5"
    case projector = "item_projector"
    case projectorDark = "projector_2"
    case projectorSide = "projector_3"
    case projectorScreen = "screen_1"
    case speakerConcert = "speaker_concert"
    case speakerDark = "speaker_dark"
    case speakerCylinder = "speaker_cyl"
    case speakerDesk = "speaker_desk2"
    case camera = "camera_1"
    case football = "football_1"
    case bottle = "bottle_green"
    case altOne = "alt_1"
    case altTwo = "alt_2"
    case damageTwo = "damage_review2"
    case damageThree = "damage_review3"
    case extraBab = "photo_bab946ba63"
    case extraC8e = "photo_c8ecf538e8"
    case extra7ff = "photo_7ff1a7e325"

    // UI art
    case payNow = "paynow"
    /// PayNow mark with the black background keyed out (Figma draws it on white).
    case payNowLogo = "paynow_logo"
    case lockScreen = "lockscreen"
    case blackFrame = "black_frame"

    var uiImage: UIImage? {
        for ext in ["png", "jpg"] {
            if let url = Bundle.main.url(forResource: rawValue, withExtension: ext),
               let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }
        return nil
    }
}

/// A bundled photo cropped to fill its frame, as Figma's FILL scale mode does.
struct PhotoView: View {
    let photo: Photo
    var contentMode: ContentMode = .fill

    var body: some View {
        Color.clear
            .overlay {
                if let image = photo.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                } else {
                    Color.track
                }
            }
            .clipped()
            .accessibilityHidden(true)
    }
}
