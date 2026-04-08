//
//  OnboardingRiderRole.swift
//  Onboarding
//

import Foundation

/// Role the user picks during onboarding.
///
/// Localised display copy lives next to the case so call sites can render
/// the role without reaching back into the strings table — the enum stays
/// the single source of truth for both identity and presentation.
enum OnboardingRiderRole: String, CaseIterable, Identifiable, Sendable {

    case rider
    case mentor

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rider:
            return OnboardingStrings.singleSportRiderTypeRiderTitle.localized
        case .mentor:
            return OnboardingStrings.singleSportRiderTypeMentorTitle.localized
        }
    }

    var description: String {
        switch self {
        case .rider:
            return OnboardingStrings.singleSportRiderTypeRiderDescription.localized
        case .mentor:
            return OnboardingStrings.singleSportRiderTypeMentorDescription.localized
        }
    }
}
