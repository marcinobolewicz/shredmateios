//
//  ForgotPasswordStrings.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

enum ForgotPasswordStrings: String {
    case navigationTitle = "forgot_password.navigation_title"
    case errorTitle = "forgot_password.error_title"
    case ok = "forgot_password.ok"
    case headerTitle = "forgot_password.header_title"
    case headerSubtitle = "forgot_password.header_subtitle"
    case emailPlaceholder = "forgot_password.email_placeholder"
    case sendResetLinkButton = "forgot_password.send_reset_link_button"
    case successTitle = "forgot_password.success_title"
    case successMessageFormat = "forgot_password.success_message_format"
    case backToSignInButton = "forgot_password.back_to_sign_in_button"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }

    static func successMessage(email: String) -> String {
        String(
            format: NSLocalizedString(
                ForgotPasswordStrings.successMessageFormat.rawValue,
                bundle: .module,
                comment: ""
            ),
            email
        )
    }
}
