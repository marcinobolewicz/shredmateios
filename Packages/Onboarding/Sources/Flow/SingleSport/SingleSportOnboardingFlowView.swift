//
//  SingleSportOnboardingFlowView.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Multi-step container for the single-sport onboarding (today: wakeboard).
///
/// Owns the current step and the navigation between steps; rendering of
/// the chrome (background, top bar, spacing) is delegated to
/// `OnboardingFlowScaffold` so this view stays focused on the variant
/// specific step graph.
struct SingleSportOnboardingFlowView: View {

    @Environment(AppTheme.self) private var theme

    let onClose: () -> Void
    let onComplete: () -> Void

    @State private var step: SingleSportOnboardingStep = .sportInfo

    var body: some View {
        OnboardingFlowScaffold(
            currentStep: step.index,
            totalSteps: SingleSportOnboardingStep.total,
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
        case .sportInfo:
            SingleSportInfoView(onContinue: { advance(to: .riderType) })
        case .riderType:
            SingleSportRiderTypeView(onSelect: { _ in onComplete() })
        }
    }

    // MARK: - Navigation

    private func advance(to next: SingleSportOnboardingStep) {
        step = next
    }

    // MARK: - Constants

    private static let backgroundAssetName = "slide_0"
    private static let transitionDuration: Double = 0.25
}

// MARK: - Preview

#Preview {
    SingleSportOnboardingFlowView(onClose: {}, onComplete: {})
        .environment(AppTheme.default)
}
