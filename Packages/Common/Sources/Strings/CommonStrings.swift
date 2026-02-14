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

    public var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
