import Foundation

public struct MentorSlot: Decodable, Sendable, Equatable, Identifiable {
    public let id: String
    public let startTime: String
    public let endTime: String
    public let duration: Int
    public let price: Int
    public let currency: String
    public let status: MentorSlotStatus
    public let paymentStatus: MentorSlotPaymentStatus?
    public let recommendationStatus: MentorSlotRecommendationStatus?
    public let mentorRider: MentorSlotRider
    public let studentRider: MentorSlotRider?
    public let sport: MentorSlotSport
    public let place: MentorSlotPlace?
}

public enum MentorSlotStatus: String, Codable, Sendable, Equatable {
    case available = "AVAILABLE"
    case booked = "BOOKED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

public enum MentorSlotPaymentStatus: String, Codable, Sendable, Equatable {
    case pending = "PENDING"
    case paid = "PAID"
    case refunded = "REFUNDED"
}

public enum MentorSlotRecommendationStatus: String, Codable, Sendable, Equatable {
    case pending = "PENDING"
    case recommended = "RECOMMENDED"
    case dismissed = "DISMISSED"
}

public struct MentorSlotRider: Decodable, Sendable, Equatable {
    public let id: String
    public let displayName: String
    public let avatarUrl: String?
    public let recommendationCount: Int?
    public let sessionCount: Int?
}

public struct MentorSlotSport: Decodable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let slug: String
}

public struct MentorSlotPlace: Decodable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let avatarUrl: String?
}

public struct MentorSlotsResponse: Decodable, Sendable {
    public let items: [MentorSlot]
    public let total: Int
}
