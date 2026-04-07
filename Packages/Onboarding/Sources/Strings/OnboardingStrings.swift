//
//  OnboardingStrings.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import Foundation

// MARK: - Type-safe localization keys for the Onboarding module.

enum OnboardingStrings: String {

    // Welcome screen
    case welcomeTitle = "welcome.title"
    case welcomeSubtitle = "welcome.subtitle"

    case welcomeHighlightSessions = "welcome.highlight.sessions"
    case welcomeHighlightAudience = "welcome.highlight.audience"
    case welcomeHighlightPersonalization = "welcome.highlight.personalization"

    case welcomeActionSignUp = "welcome.action.sign_up"
    case welcomeActionSignIn = "welcome.action.sign_in"

    case welcomeLogoAccessibility = "welcome.accessibility.logo"
    case welcomeCloseAccessibility = "welcome.accessibility.close"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
