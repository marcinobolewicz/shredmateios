import Foundation

public protocol MentorSlotsServiceProtocol: Sendable {
    func fetchSlots(
        mentorRiderId: String,
        from: String?,
        to: String?,
        limit: Int
    ) async throws -> MentorSlotsResponse

    func fetchMySlots() async throws -> MentorSlotsResponse
    func fetchBookedByMe() async throws -> MentorSlotsResponse
    func bookSlot(id: String) async throws -> MentorSlot
    func cancelBooking(id: String) async throws -> MentorSlot
    func completeSession(id: String, recommend: Bool) async throws -> MentorSlot
    func deleteSlot(id: String) async throws
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

    public func fetchMySlots() async throws -> MentorSlotsResponse {
        try await client.send(MentorSlotsAPI.mySlots())
    }

    public func fetchBookedByMe() async throws -> MentorSlotsResponse {
        try await client.send(MentorSlotsAPI.bookedByMe())
    }

    public func bookSlot(id: String) async throws -> MentorSlot {
        try await client.send(MentorSlotsAPI.bookSlot(id: id))
    }

    public func cancelBooking(id: String) async throws -> MentorSlot {
        try await client.send(MentorSlotsAPI.cancelBooking(id: id))
    }

    public func completeSession(id: String, recommend: Bool) async throws -> MentorSlot {
        try await client.send(MentorSlotsAPI.completeSession(id: id, recommend: recommend))
    }

    public func deleteSlot(id: String) async throws {
        _ = try await client.send(MentorSlotsAPI.deleteSlot(id: id))
    }
}
