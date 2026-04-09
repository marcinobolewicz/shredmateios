//
//  OnboardingFlowScaffold.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Shared chrome for every onboarding flow variant.
///
/// Renders the scrim background, the top bar (close + progress) and the
/// active step view supplied by the caller. Concrete flows (single- vs
/// multi-sport) plug their own step content here, so the visual frame and
/// the safe-area / spacing rules stay identical across variants while the
/// step content remains free to differ.
struct OnboardingFlowScaffold<StepContent: View>: View {

    @Environment(AppTheme.self) private var theme

    let currentStep: Int
    let totalSteps: Int
    let backgroundAssetName: String
    let onClose: () -> Void
    @ViewBuilder let stepContent: () -> StepContent

    var body: some View {
        VStack(spacing: theme.spacing.xl) {
            OnboardingTopBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                onClose: onClose
            )
            .padding(.top, theme.spacing.md)

            Spacer(minLength: 0)

            stepContent()
                .transition(.opacity)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, theme.spacing.lg)
        .safeAreaPadding()
        .dsScrimBackground(backgroundAssetName)
    }
}
