//
//  OnboardingView.swift
//  Onboarding
//

import SwiftUI
import Networking

/// Public entry point for the post-registration onboarding.
///
/// Acts as a thin router: when the backend currently exposes a single
/// sport we run the dedicated single-sport flow (today: wakeboard only),
/// otherwise we run the multi-sport flow. The two flows are intentionally
/// independent — different copy, different steps, different progression —
/// so neither has to compromise to fit the other's shape.
public struct OnboardingView: View {

    private let sportsCount: Int
    private let sportId: String?
    private let riderService: any RiderServiceProtocol
    private let onClose: () -> Void
    private let onComplete: (OnboardingDestination) -> Void

    /// - Parameters:
    ///   - sportsCount: Number of sports the backend currently exposes.
    ///   - sportId: Identifier of the single sport (when there is one). Used
    ///     by the single-sport flow to upsert the rider's role.
    ///   - riderService: Service used to persist the rider's sport profile.
    ///   - onClose: Invoked when the user dismisses the flow via the X button.
    ///   - onComplete: Invoked once the user finishes the last step. The
    ///     payload tells the host where to land the user next.
    public init(
        sportsCount: Int,
        sportId: String?,
        riderService: any RiderServiceProtocol,
        onClose: @escaping () -> Void,
        onComplete: @escaping (OnboardingDestination) -> Void
    ) {
        self.sportsCount = sportsCount
        self.sportId = sportId
        self.riderService = riderService
        self.onClose = onClose
        self.onComplete = onComplete
    }

    public var body: some View {
        if sportsCount > 1 || sportId == nil {
            MultiSportOnboardingFlowView(onClose: onClose, onComplete: onComplete)
        } else {
            SingleSportOnboardingFlowView(
                viewModel: SingleSportOnboardingViewModel(
                    riderService: riderService,
                    sportId: sportId ?? ""
                ),
                onClose: onClose,
                onComplete: onComplete
            )
        }
    }
}
