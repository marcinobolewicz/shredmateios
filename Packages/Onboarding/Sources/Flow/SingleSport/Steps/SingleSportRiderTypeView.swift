//
//  SingleSportRiderTypeView.swift
//  Onboarding
//

import SwiftUI

/// Single-sport flow — step 2.
///
/// Asks the user how they want to use ShredMate inside the single-sport
/// world (rider vs mentor). Currently a placeholder card; the actual role
/// pickers will land in a follow-up. The primary `Done` action confirms
/// the flow is finished.
struct SingleSportRiderTypeView: View {

    let onDone: () -> Void

    var body: some View {
        OnboardingStepCard(
            title: OnboardingStrings.singleSportRiderTypeTitle.localized,
            description: OnboardingStrings.singleSportRiderTypeDescription.localized,
            actionTitle: OnboardingStrings.onboardingActionDone.localized,
            onAction: onDone
        )
    }
}
