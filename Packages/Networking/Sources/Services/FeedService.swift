import Foundation

public protocol FeedServiceProtocol: Sendable {
    func createActivity(_ request: CreateActivityRequest) async throws -> ActivityPost
    func fetchFeed(page: Int, limit: Int) async throws -> PaginatedResponse<ActivityPost>
}

public final class FeedService: FeedServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func createActivity(_ request: CreateActivityRequest) async throws -> ActivityPost {
        try await client.send(FeedAPI.createActivity(request))
    }

    public func fetchFeed(page: Int, limit: Int = 20) async throws -> PaginatedResponse<ActivityPost> {
        try await client.send(FeedAPI.feed(page: page, limit: limit))
    }
}
