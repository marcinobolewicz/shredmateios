//
//  SingleSportOnboardingFlowView.swift
//  Onboarding
//

import SwiftUI
import Networking
import Theme

/// Multi-step container for the single-sport onboarding (today: wakeboard).
///
/// Owns the current step, the picked role and the rider-sport upserts;
/// rendering of the chrome (background, top bar, spacing) is delegated to
/// `OnboardingFlowScaffold` so this view stays focused on the variant
/// specific step graph.
struct SingleSportOnboardingFlowView: View {

    @Environment(AppTheme.self) private var theme

    let viewModel: SingleSportOnboardingViewModel
    let onClose: () -> Void
    let onComplete: (OnboardingDestination) -> Void

    @State private var step: SingleSportOnboardingStep = .sportInfo
    @State private var selectedRole: OnboardingRiderRole = .rider

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
                .task { await viewModel.registerAsRider() }
        case .riderType:
            SingleSportRiderTypeView(onSelect: handleRoleSelected)
        case .success:
            SingleSportSuccessView(role: selectedRole, onPick: onComplete)
        }
    }

    // MARK: - Step transitions

    private func handleRoleSelected(_ role: OnboardingRiderRole) {
        selectedRole = role
        if role == .mentor {
            Task { await viewModel.registerAsMentor() }
        }
        advance(to: .success)
    }

    private func advance(to next: SingleSportOnboardingStep) {
        step = next
    }

    // MARK: - Constants

    private static let backgroundAssetName = "slide_0"
    private static let transitionDuration: Double = 0.25
}
