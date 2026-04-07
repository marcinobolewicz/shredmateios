//
//  OnboardingProgressBar.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Linear progress bar showing how far the user has advanced through the
/// onboarding flow. Fully driven by the current step / total step counts;
/// no internal state. The fill animates whenever the bound values change.
struct OnboardingProgressBar: View {

    @Environment(AppTheme.self) private var theme

    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            bar
            label
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Subviews

    private var bar: some View {
        ProgressView(value: progress)
            .progressViewStyle(.linear)
            .tint(theme.colors.primaryForeground)
            .animation(.easeInOut(duration: Self.fillAnimationDuration), value: progress)
    }

    private var label: some View {
        Text(label(for: currentStep, of: totalSteps))
            .font(.caption.weight(.medium))
            .foregroundStyle(theme.colors.primaryForeground.opacity(Self.labelOpacity))
            .monospacedDigit()
    }

    // MARK: - Helpers

    private var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps)
    }

    private func label(for current: Int, of total: Int) -> String {
        String(
            format: OnboardingStrings.onboardingProgressLabel.localized,
            current,
            total
        )
    }

    private var accessibilityLabel: String {
        String(
            format: OnboardingStrings.onboardingProgressAccessibility.localized,
            currentStep,
            totalSteps
        )
    }

    // MARK: - Tuning

    private static let fillAnimationDuration: Double = 0.25
    private static let labelOpacity: Double = 0.75
}
