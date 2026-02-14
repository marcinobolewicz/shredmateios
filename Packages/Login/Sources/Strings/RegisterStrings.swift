//
//  RegisterStrings.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

enum RegisterStrings: String {
    case navigationTitle = "register.navigation_title"
    case headerTitle = "register.header_title"
    case namePlaceholder = "register.name_placeholder"
    case emailPlaceholder = "register.email_placeholder"
    case passwordPlaceholder = "register.password_placeholder"
    case confirmPasswordPlaceholder = "register.confirm_password_placeholder"
    case passwordMismatch = "register.password_mismatch"
    case passwordHint = "register.password_hint"
    case createAccountButton = "register.create_account_button"
    case alreadyHaveAccount = "register.already_have_account"
    case signInButton = "register.sign_in_button"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
