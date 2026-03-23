import Foundation

public protocol FeedServiceProtocol: Sendable {
    func createActivity(_ request: CreateActivityRequest) async throws -> ActivityPost
    func uploadPhoto(imageData: Data) async throws -> ActivityPhotoUploadResponse
    func fetchFeed(page: Int, limit: Int) async throws -> PaginatedResponse<ActivityPost>
    func fetchRiderPosts(riderId: String, page: Int, limit: Int) async throws -> PaginatedResponse<ActivityPost>
    func deleteActivity(activityId: String) async throws
}

public final class FeedService: FeedServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func createActivity(_ request: CreateActivityRequest) async throws -> ActivityPost {
        try await client.send(FeedAPI.createActivity(request))
    }

    public func uploadPhoto(imageData: Data) async throws -> ActivityPhotoUploadResponse {
        try await client.send(FeedAPI.uploadPhoto(imageData: imageData))
    }

    public func fetchFeed(page: Int, limit: Int = 20) async throws -> PaginatedResponse<ActivityPost> {
        try await client.send(FeedAPI.feed(page: page, limit: limit))
    }

    public func fetchRiderPosts(riderId: String, page: Int, limit: Int = 20) async throws -> PaginatedResponse<ActivityPost> {
        try await client.send(FeedAPI.riderFeed(riderId: riderId, page: page, limit: limit))
    }

    public func deleteActivity(activityId: String) async throws {
        _ = try await client.send(FeedAPI.deleteActivity(activityId: activityId))
    }
}
