//
//  OnboardingTopBar.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Top row of the onboarding flow: close button on the leading edge and
/// the linear progress bar filling the remaining horizontal space.
struct OnboardingTopBar: View {

    @Environment(AppTheme.self) private var theme

    let currentStep: Int
    let totalSteps: Int
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: theme.spacing.md) {
            DSCloseButton(
                accessibilityLabel: OnboardingStrings.onboardingCloseAccessibility.localized,
                action: onClose
            )

            OnboardingProgressBar(
                currentStep: currentStep,
                totalSteps: totalSteps
            )
        }
    }
}
