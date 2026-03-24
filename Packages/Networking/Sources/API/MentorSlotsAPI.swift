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

    public static func bookSlot(id: String) -> Endpoint<MentorSlot> {
        .post("/mentor-slots/\(id)/book", auth: .bearerToken)
    }

    public static func deleteSlot(id: String) -> Endpoint<EmptyResponse> {
        .delete("/mentor-slots/\(id)", auth: .bearerToken)
    }
}
