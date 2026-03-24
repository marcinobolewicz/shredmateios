import Foundation

public protocol MentorSlotsServiceProtocol: Sendable {
    func fetchSlots(
        mentorRiderId: String,
        from: String?,
        to: String?,
        limit: Int
    ) async throws -> MentorSlotsResponse
}

public final class MentorSlotsService: MentorSlotsServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func fetchSlots(
        mentorRiderId: String,
        from: String? = nil,
        to: String? = nil,
        limit: Int = 100
    ) async throws -> MentorSlotsResponse {
        try await client.send(
            MentorSlotsAPI.slots(
                mentorRiderId: mentorRiderId,
                from: from,
                to: to,
                limit: limit
            )
        )
    }
}
