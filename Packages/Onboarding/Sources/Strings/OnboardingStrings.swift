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
    case singleSportRiderTypeRiderTitle = "onboarding.single_sport.rider_type.rider.title"
    case singleSportRiderTypeRiderDescription = "onboarding.single_sport.rider_type.rider.description"
    case singleSportRiderTypeMentorTitle = "onboarding.single_sport.rider_type.mentor.title"
    case singleSportRiderTypeMentorDescription = "onboarding.single_sport.rider_type.mentor.description"
    case singleSportRiderTypeFootnote = "onboarding.single_sport.rider_type.footnote"

    case singleSportSuccessRiderTitle = "onboarding.single_sport.success.rider.title"
    case singleSportSuccessRiderDescription = "onboarding.single_sport.success.rider.description"
    case singleSportSuccessRiderBulletOne = "onboarding.single_sport.success.rider.bullet.one"
    case singleSportSuccessRiderBulletTwo = "onboarding.single_sport.success.rider.bullet.two"
    case singleSportSuccessRiderBulletThree = "onboarding.single_sport.success.rider.bullet.three"

    case singleSportSuccessMentorTitle = "onboarding.single_sport.success.mentor.title"
    case singleSportSuccessMentorDescription = "onboarding.single_sport.success.mentor.description"
    case singleSportSuccessMentorBulletOne = "onboarding.single_sport.success.mentor.bullet.one"
    case singleSportSuccessMentorBulletTwo = "onboarding.single_sport.success.mentor.bullet.two"
    case singleSportSuccessMentorBulletThree = "onboarding.single_sport.success.mentor.bullet.three"

    case singleSportSuccessActionEditProfile = "onboarding.single_sport.success.action.edit_profile"
    case singleSportSuccessActionExplorePlaces = "onboarding.single_sport.success.action.explore_places"
    case singleSportSuccessActionFindMentor = "onboarding.single_sport.success.action.find_mentor"
    case singleSportSuccessActionAddSlots = "onboarding.single_sport.success.action.add_slots"

    // Onboarding — multi-sport flow (placeholder copy until design lands)
    case multiSportPickSportsTitle = "onboarding.multi_sport.pick_sports.title"
    case multiSportPickSportsDescription = "onboarding.multi_sport.pick_sports.description"

    case multiSportRiderTypeTitle = "onboarding.multi_sport.rider_type.title"
    case multiSportRiderTypeDescription = "onboarding.multi_sport.rider_type.description"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }
}
