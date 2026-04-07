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

    // Onboarding — shared chrome (used by both single- and multi-sport flows)
    case onboardingActionContinue = "onboarding.action.continue"
    case onboardingActionDone = "onboarding.action.done"

    case onboardingCloseAccessibility = "onboarding.accessibility.close"
    case onboardingProgressAccessibility = "onboarding.accessibility.progress"
    case onboardingProgressLabel = "onboarding.progress.label"

    // Onboarding — single-sport flow
    case singleSportInfoTitle = "onboarding.single_sport.info.title"
    case singleSportInfoDescription = "onboarding.single_sport.info.description"
    case singleSportInfoBulletParks = "onboarding.single_sport.info.bullet.parks"
    case singleSportInfoBulletSessions = "onboarding.single_sport.info.bullet.sessions"
    case singleSportInfoBulletMore = "onboarding.single_sport.info.bullet.more"

    case singleSportRiderTypeTitle = "onboarding.single_sport.rider_type.title"
    case singleSportRiderTypeDescription = "onboarding.single_sport.rider_type.description"

    // Onboarding — multi-sport flow (placeholder copy until design lands)
    case multiSportPickSportsTitle = "onboarding.multi_sport.pick_sports.title"
    case multiSportPickSportsDescription = "onboarding.multi_sport.pick_sports.description"

    case multiSportRiderTypeTitle = "onboarding.multi_sport.rider_type.title"
    case multiSportRiderTypeDescription = "onboarding.multi_sport.rider_type.description"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
