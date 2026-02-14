//
//  LoginStrings.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

// MARK: - Type-safe localization keys for Login module

enum LoginStrings: String {
    case navigationTitle = "login.navigation_title"
    case appName = "login.app_name"
    case subtitle = "login.subtitle"
    case emailPlaceholder = "login.email_placeholder"
    case passwordPlaceholder = "login.password_placeholder"
    case signInButton = "login.sign_in_button"
    case forgotPasswordButton = "login.forgot_password_button"
    case noAccountPrompt = "login.no_account_prompt"
    case signUpButton = "login.sign_up_button"
    case errorTitle = "login.error_title"
    case ok = "login.ok"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }

    // MARK: - Parameterized strings (example pattern for future use)

    // Usage: `LoginStrings.unreadCount(5)`
    // Requires key "login.unread_count" = "You have %d unread messages"; in .strings
    // static func unreadCount(_ count: Int) -> String {
    //     String(format: NSLocalizedString("login.unread_count", bundle: .module, comment: ""), count)
    // }
}
