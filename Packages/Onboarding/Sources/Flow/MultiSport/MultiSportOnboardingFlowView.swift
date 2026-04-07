//
//  MultiSportOnboardingFlowView.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Multi-step container for the multi-sport onboarding.
///
/// Mirrors `SingleSportOnboardingFlowView` in shape but is intentionally
/// kept as a separate flow: the multi-sport story will get its own copy,
/// pickers and step graph as soon as design is ready. Today the steps are
/// thin placeholders so the flow can be exercised end-to-end.
struct MultiSportOnboardingFlowView: View {

    @Environment(AppTheme.self) private var theme

    let onClose: () -> Void
    let onComplete: () -> Void

    @State private var step: MultiSportOnboardingStep = .pickSports

    var body: some View {
        OnboardingFlowScaffold(
            currentStep: step.index,
            totalSteps: MultiSportOnboardingStep.total,
            backgroundAssetName: Self.backgroundAssetName,
            onClose: onClose,
            stepContent: { currentStepView }
        )
        .animation(.easeInOut(duration: Self.transitionDuration), value: step)
    }

    // MARK: - Steps

    @ViewBuilder
    private var currentStepView: some View {
        switch step {
        case .pickSports:
            MultiSportPickSportsView(onContinue: { advance(to: .riderType) })
        case .riderType:
            MultiSportRiderTypeView(onDone: onComplete)
        }
    }

    // MARK: - Navigation

    private func advance(to next: MultiSportOnboardingStep) {
        step = next
    }

    // MARK: - Constants

    private static let backgroundAssetName = "slide_0"
    private static let transitionDuration: Double = 0.25
}

// MARK: - Preview

#Preview {
    MultiSportOnboardingFlowView(onClose: {}, onComplete: {})
        .environment(AppTheme.default)
}
