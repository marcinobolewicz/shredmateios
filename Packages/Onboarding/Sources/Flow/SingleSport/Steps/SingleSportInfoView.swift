//
//  SingleSportInfoView.swift
//  Onboarding
//

import SwiftUI

/// Single-sport flow — step 1.
///
/// Sets the product context for new users (today: wakeboard only) and
/// previews the kind of value the app will deliver before they advance to
/// the role pick.
struct SingleSportInfoView: View {

    let onContinue: () -> Void

    var body: some View {
        OnboardingStepCard(
            title: OnboardingStrings.singleSportInfoTitle.localized,
            description: OnboardingStrings.singleSportInfoDescription.localized,
            actionTitle: OnboardingStrings.onboardingActionContinue.localized,
            onAction: onContinue
        ) {
            OnboardingBulletList(items: Self.bulletItems)
        }
    }

    // MARK: - Content

    private static let bulletItems: [String] = [
        OnboardingStrings.singleSportInfoBulletParks.localized,
        OnboardingStrings.singleSportInfoBulletSessions.localized,
        OnboardingStrings.singleSportInfoBulletMore.localized
    ]
}
