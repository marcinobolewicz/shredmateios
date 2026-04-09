//
//  SingleSportOnboardingViewModel.swift
//  Onboarding
//

import Foundation
import Networking

/// Owns the network side of the single-sport onboarding flow.
///
/// The flow upserts the rider's sport twice in the worst case: once with
/// the default rider profile after the intro step, and again as a mentor
/// if the user picks the mentor role on step two. The view model exposes
/// a single entry point per write so step views stay declarative and free
/// of `RiderService` knowledge.
@MainActor
final class SingleSportOnboardingViewModel {

    private let riderService: any RiderServiceProtocol
    private let sportId: String

    init(riderService: any RiderServiceProtocol, sportId: String) {
        self.riderService = riderService
        self.sportId = sportId
    }

    /// Marks the rider as a casual participant of the sport. Failures are
    /// swallowed on purpose: a transient network blip must not block the
    /// user from finishing onboarding — the profile screen will let them
    /// fix the level later.
    func registerAsRider() async {
        await upsert(isMentor: false)
    }

    /// Promotes the same rider sport entry to a mentor. Same failure
    /// policy as `registerAsRider()`.
    func registerAsMentor() async {
        await upsert(isMentor: true)
    }

    private func upsert(isMentor: Bool) async {
        let request = UpsertRiderSportRequest(level: .casual, isMentor: isMentor)
        do {
            _ = try await riderService.upsertMyRiderSport(sportId: sportId, request: request)
        } catch {
            // Intentionally swallowed — see doc comment.
        }
    }
}
