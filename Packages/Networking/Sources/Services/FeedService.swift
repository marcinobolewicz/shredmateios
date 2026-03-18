import Foundation

public protocol FeedServiceProtocol: Sendable {
    func createActivity(_ request: CreateActivityRequest) async throws -> ActivityPost
}

public final class FeedService: FeedServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func createActivity(_ request: CreateActivityRequest) async throws -> ActivityPost {
        try await client.send(FeedAPI.createActivity(request))
    }
}
