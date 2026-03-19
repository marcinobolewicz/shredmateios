import Foundation
import Observation

/// Session-scoped cache of followed rider IDs.
/// Load once per session; updates optimistically on follow/unfollow.
@MainActor
@Observable
public final class FollowRepository {

    public private(set) var followedRiderIds: Set<String> = []
    private var isLoaded = false

    private let riderService: any RiderServiceProtocol
    private let authState: AuthState

    public init(riderService: any RiderServiceProtocol, authState: AuthState) {
        self.riderService = riderService
        self.authState = authState
    }

    // MARK: - Load

    public func loadIfNeeded() async {
        guard !isLoaded, let riderId = authState.rider?.id else { return }
        do {
            let riders = try await riderService.fetchFollowing(riderId: riderId)
            followedRiderIds = Set(riders.map(\.id))
            isLoaded = true
        } catch {
            // Non-critical; will retry on next check
        }
    }

    // MARK: - Query

    public func isFollowing(riderId: String) -> Bool {
        followedRiderIds.contains(riderId)
    }

    // MARK: - Mutations

    public func follow(riderId: String) async throws {
        try await riderService.follow(riderId: riderId)
        followedRiderIds.insert(riderId)
    }

    public func unfollow(riderId: String) async throws {
        try await riderService.unfollow(riderId: riderId)
        followedRiderIds.remove(riderId)
    }

    // MARK: - Session

    public func reset() {
        isLoaded = false
        followedRiderIds = []
    }
}
