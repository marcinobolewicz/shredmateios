import Foundation

public enum CommonStrings: String {
    case genericErrorTitle = "common.generic_error_title"
    case genericErrorMessage = "common.generic_error_message"
    case genericErrorRecovery = "common.generic_error_recovery"

    case errorTitle = "common.error_title"
    case retryButton = "common.retry_button"
    case okButton = "common.ok_button"
    case cancelButton = "common.cancel_button"
    case sendButton = "common.send_button"

    case sessionExpiredTitle = "common.session_expired_title"
    case sessionExpiredMessage = "common.session_expired_message"

    // MARK: - Location Picker
    case locationPickerTitle = "common.location_picker_title"
    case locationPickerConfirm = "common.location_picker_confirm"
    case locationPickerTapHint = "common.location_picker_tap_hint"

    public var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
