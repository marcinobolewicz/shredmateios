import Foundation

public enum MentorSlotsAPI {

    public static func slots(
        mentorRiderId: String,
        status: MentorSlotStatus? = .available,
        from: String? = nil,
        to: String? = nil,
        limit: Int = 100
    ) -> Endpoint<MentorSlotsResponse> {
        var query: [URLQueryItem] = [
            URLQueryItem(name: "mentorRiderId", value: mentorRiderId),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let status {
            query.append(URLQueryItem(name: "status", value: status.rawValue))
        }
        if let from {
            query.append(URLQueryItem(name: "from", value: from))
        }
        if let to {
            query.append(URLQueryItem(name: "to", value: to))
        }
        return .get("/mentor-slots", query: query, auth: .bearerToken)
    }

    public static func mySlots(limit: Int = 100) -> Endpoint<MentorSlotsResponse> {
        .get("/mentor-slots/my", query: [URLQueryItem(name: "limit", value: String(limit))], auth: .bearerToken)
    }

    public static func bookedByMe() -> Endpoint<MentorSlotsResponse> {
        .get("/mentor-slots/booked-by-me", auth: .bearerToken)
    }

    public static func bookSlot(id: String) -> Endpoint<MentorSlot> {
        .post("/mentor-slots/\(id)/book", auth: .bearerToken)
    }

    public static func cancelBooking(id: String) -> Endpoint<MentorSlot> {
        .post("/mentor-slots/\(id)/cancel", auth: .bearerToken)
    }

    public static func completeSession(id: String, recommend: Bool) -> Endpoint<MentorSlot> {
        .post("/mentor-slots/\(id)/complete", body: CompleteSessionBody(recommend: recommend), auth: .bearerToken)
    }

    public static func deleteSlot(id: String) -> Endpoint<EmptyResponse> {
        .delete("/mentor-slots/\(id)", auth: .bearerToken)
    }

    public static func generateSlots(request: GenerateSlotsRequest) -> Endpoint<GenerateSlotsResponse> {
        .post("/mentor-slots/generate", body: request, auth: .bearerToken)
    }
}

struct CompleteSessionBody: Encodable, Sendable {
    let recommend: Bool
}

public struct GenerateSlotsRequest: Encodable, Sendable {
    public let sportId: String
    public let placeId: String?
    public let weekdays: [Int]
    public let timeFrom: String
    public let timeTo: String
    public let duration: Int
    public let price: Int
    public let startDate: String
    public let endDate: String

    public init(
        sportId: String,
        placeId: String?,
        weekdays: [Int],
        timeFrom: String,
        timeTo: String,
        duration: Int,
        price: Int,
        startDate: String,
        endDate: String
    ) {
        self.sportId = sportId
        self.placeId = placeId
        self.weekdays = weekdays
        self.timeFrom = timeFrom
        self.timeTo = timeTo
        self.duration = duration
        self.price = price
        self.startDate = startDate
        self.endDate = endDate
    }
}

public struct GenerateSlotsResponse: Decodable, Sendable {
    public let generated: Int
    public let skipped: Int
    public let skippedSlots: [SkippedSlot]

    public struct SkippedSlot: Decodable, Sendable {
        public let startTime: String
        public let endTime: String
    }
}
