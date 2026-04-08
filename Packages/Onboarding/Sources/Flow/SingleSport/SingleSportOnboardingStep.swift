//
//  SingleSportOnboardingStep.swift
//  Onboarding
//

import Foundation

/// Linear sequence of screens for the single-sport onboarding flow.
///
/// Order matches `allCases`; `index` is 1-based for display in the
/// progress bar. Adding a new step here automatically updates the bar and
/// the flow container `switch`.
enum SingleSportOnboardingStep: Int, CaseIterable, Sendable {

    case sportInfo
    case riderType
    case success

    var index: Int { rawValue + 1 }

    static var total: Int { allCases.count }
}
