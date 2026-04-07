//
//  MultiSportOnboardingStep.swift
//  Onboarding
//

import Foundation

/// Linear sequence of screens for the multi-sport onboarding flow.
///
/// Currently mirrors the single-sport flow's step count to keep the
/// progress bar meaningful while the multi-sport screens are still
/// placeholders. The set will diverge from the single-sport variant as
/// real designs land.
enum MultiSportOnboardingStep: Int, CaseIterable, Sendable {

    case pickSports
    case riderType

    var index: Int { rawValue + 1 }

    static var total: Int { allCases.count }
}
