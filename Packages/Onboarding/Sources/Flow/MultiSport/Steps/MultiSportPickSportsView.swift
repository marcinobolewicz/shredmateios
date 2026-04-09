//
//  MultiSportPickSportsView.swift
//  Onboarding
//

import SwiftUI

/// Multi-sport flow — step 1.
///
/// Will let the user pick the disciplines they ride. Currently a
/// placeholder card while the rest of the multi-sport story is designed.
struct MultiSportPickSportsView: View {

    let onContinue: () -> Void

    var body: some View {
        OnboardingStepCard(
            title: OnboardingStrings.multiSportPickSportsTitle.localized,
            description: OnboardingStrings.multiSportPickSportsDescription.localized,
            actionTitle: OnboardingStrings.onboardingActionContinue.localized,
            onAction: onContinue
        )
    }
}
