//
//  OnboardingDestination.swift
//  Onboarding
//

import Foundation

/// Final intent expressed by the user on the last onboarding step.
///
/// The onboarding flow does not own the rest of the app — it returns one
/// of these values to the host so the host can land the user on the right
/// place (a tab, a deep link inside profile, …) without onboarding having
/// to know what those destinations look like.
public enum OnboardingDestination: Sendable, Equatable {
    case editProfile
    case explorePlaces
    case findMentor
    case addSlots
}
