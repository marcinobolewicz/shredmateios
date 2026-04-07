//
//  MultiSportRiderTypeView.swift
//  Onboarding
//

import SwiftUI

/// Multi-sport flow — step 2.
///
/// Will ask the user how they want to use ShredMate across the picked
/// disciplines. Currently a placeholder card; copy and inputs will land
/// once design is ready.
struct MultiSportRiderTypeView: View {

    let onDone: () -> Void

    var body: some View {
        OnboardingStepCard(
            title: OnboardingStrings.multiSportRiderTypeTitle.localized,
            description: OnboardingStrings.multiSportRiderTypeDescription.localized,
            actionTitle: OnboardingStrings.onboardingActionDone.localized,
            onAction: onDone
        )
    }
}
