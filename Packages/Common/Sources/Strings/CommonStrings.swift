import Foundation

enum CommonStrings: String {
    case genericErrorTitle = "common.generic_error_title"
    case genericErrorMessage = "common.generic_error_message"
    case genericErrorRecovery = "common.generic_error_recovery"

    case retryButton = "common.retry_button"
    case okButton = "common.ok_button"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
