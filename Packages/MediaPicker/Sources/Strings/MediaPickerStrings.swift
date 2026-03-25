import Foundation

enum MediaPickerStrings: String {
    case usePhotoButton = "mediapicker.use_photo_button"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
