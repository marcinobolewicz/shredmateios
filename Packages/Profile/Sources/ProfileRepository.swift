import Foundation
import Networking

protocol ProfileRepositoryProtocol: Sendable {
    func fetchProfileSnapshot() async throws -> ProfileSnapshot
    func updateProfile(_ request: UpdateRiderRequest) async throws -> Rider
    func uploadAvatar(_ imageData: Data) async throws -> AvatarUploadResponse
    func updateBaseLocation(_ request: UpdateBaseLocationRequest) async throws -> RiderBaseLocation
    func upsertSport(sportId: String, request: UpsertRiderSportRequest) async throws -> RiderSport
    func removeSport(sportId: String) async throws
    func deleteAccount() async throws
}

struct ProfileSnapshot: Sendable {
    let rider: Rider
    let baseLocation: RiderBaseLocation?
    let sports: [Sport]
    let riderSports: [RiderSport]
}

final class ProfileRepository: ProfileRepositoryProtocol, Sendable {
    private let riderService: any RiderServiceProtocol
    private let sportsService: any SportsServiceProtocol

    init(riderService: any RiderServiceProtocol, sportsService: any SportsServiceProtocol) {
        self.riderService = riderService
        self.sportsService = sportsService
    }

    func fetchProfileSnapshot() async throws -> ProfileSnapshot {
        async let riderTask = riderService.fetchMyRider()
        async let baseLocationTask = fetchBaseLocationSafely()
        async let sportsTask = fetchSportsSafely()
        async let riderSportsTask = fetchRiderSportsSafely()

        return try await ProfileSnapshot(
            rider: riderTask,
            baseLocation: baseLocationTask,
            sports: sportsTask,
            riderSports: riderSportsTask
        )
    }

    func updateProfile(_ request: UpdateRiderRequest) async throws -> Rider {
        try await riderService.updateMyRider(request)
    }

    func uploadAvatar(_ imageData: Data) async throws -> AvatarUploadResponse {
        try await riderService.uploadAvatar(imageData)
    }

    func updateBaseLocation(_ request: UpdateBaseLocationRequest) async throws -> RiderBaseLocation {
        try await riderService.updateMyBaseLocation(request)
    }

    func upsertSport(sportId: String, request: UpsertRiderSportRequest) async throws -> RiderSport {
        try await riderService.upsertMyRiderSport(sportId: sportId, request: request)
    }

    func removeSport(sportId: String) async throws {
        try await riderService.deleteMyRiderSport(sportId: sportId)
    }

    func deleteAccount() async throws {
        try await riderService.deleteMyAccount()
    }

    private func fetchBaseLocationSafely() async -> RiderBaseLocation? {
        do {
            return try await riderService.fetchMyBaseLocation()
        } catch {
            return nil
        }
    }

    private func fetchSportsSafely() async -> [Sport] {
        do {
            return try await sportsService.fetchSports()
        } catch {
            return []
        }
    }

    private func fetchRiderSportsSafely() async -> [RiderSport] {
        do {
            return try await riderService.fetchMyRiderSports()
        } catch {
            return []
        }
    }
}
