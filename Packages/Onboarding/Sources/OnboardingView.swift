//
//  OnboardingView.swift
//  Onboarding
//

import SwiftUI

/// Public entry point for the post-registration onboarding.
///
/// Acts as a thin router: when the backend currently exposes a single
/// sport we run the dedicated single-sport flow (today: wakeboard only),
/// otherwise we run the multi-sport flow. The two flows are intentionally
/// independent — different copy, different steps, different progression —
/// so neither has to compromise to fit the other's shape.
public struct OnboardingView: View {

    private let sportsCount: Int
    private let onClose: () -> Void
    private let onComplete: () -> Void

    /// - Parameters:
    ///   - sportsCount: Number of sports the backend currently exposes.
    ///   - onClose: Invoked when the user dismisses the flow via the X button.
    ///   - onComplete: Invoked after the final step is confirmed.
    public init(
        sportsCount: Int,
        onClose: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) {
        self.sportsCount = sportsCount
        self.onClose = onClose
        self.onComplete = onComplete
    }

    public var body: some View {
        if sportsCount > 1 {
            MultiSportOnboardingFlowView(onClose: onClose, onComplete: onComplete)
        } else {
            SingleSportOnboardingFlowView(onClose: onClose, onComplete: onComplete)
        }
    }
}
