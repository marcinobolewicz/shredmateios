import Foundation

public protocol MentorsServiceProtocol: Sendable {
    func fetchMentors(sportId: UUID?, placeId: UUID?, page: Int, limit: Int) async throws -> PaginatedResponse<MentorListItem>
}

public final class MentorsService: MentorsServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func fetchMentors(
        sportId: UUID? = nil,
        placeId: UUID? = nil,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> PaginatedResponse<MentorListItem> {
        try await client.send(MentorsAPI.mentors(sportId: sportId, placeId: placeId, page: page, limit: limit))
    }
}
