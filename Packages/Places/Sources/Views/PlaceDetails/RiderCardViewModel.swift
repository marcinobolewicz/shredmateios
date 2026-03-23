import Foundation
import Networking
import Common

@MainActor
@Observable
final class RiderCardViewModel {

    private(set) var isFollowing = false
    private(set) var isLoading = false
    var error: AppError?

    private let riderId: String
    private let followRepository: FollowRepository

    init(riderId: String, followRepository: FollowRepository) {
        self.riderId = riderId
        self.followRepository = followRepository
    }

    func loadOnAppear() async {
        await followRepository.loadIfNeeded()
        isFollowing = followRepository.isFollowing(riderId: riderId)
    }

    func toggleFollow() {
        isLoading = true
        error = nil

        Task { [weak self] in
            guard let self else { return }
            defer { self.isLoading = false }
            do {
                if isFollowing {
                    try await followRepository.unfollow(riderId: riderId)
                } else {
                    try await followRepository.follow(riderId: riderId)
                }
                isFollowing = followRepository.isFollowing(riderId: riderId)
            } catch {
                self.error = .from(error)
            }
        }
    }
}
