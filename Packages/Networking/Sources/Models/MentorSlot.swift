import Foundation

public struct MentorSlot: Decodable, Sendable, Equatable, Identifiable {
    public let id: String
    public let startTime: String
    public let endTime: String
    public let duration: Int
    public let price: Int
    public let currency: String
    public let rejectionMessage: String?
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
    case rejected = "REJECTED"
    case reservationPending = "RESERVATION_PENDING"
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

// MARK: - Payment Intent

public struct PaymentIntentResponse: Decodable, Sendable {
    public let paymentIntentId: String
    public let clientSecret: String
    public let amount: Int
    public let currency: String
    public let publishableKey: String
}

public struct ConfirmPaymentBody: Encodable, Sendable {
    public let paymentIntentId: String

    public init(paymentIntentId: String) {
        self.paymentIntentId = paymentIntentId
    }
}

public struct ConfirmPaymentResponse: Decodable, Sendable {
    public let status: String
    public let slot: ConfirmedSlot

    public struct ConfirmedSlot: Decodable, Sendable {
        public let id: String
        public let startTime: String
        public let mentorRider: Rider
        public let studentRider: Student?
        public let sport: MentorSlotSport
        public let place: MentorSlotPlace?

        public struct Rider: Decodable, Sendable {
            public let displayName: String
        }

        public struct Student: Decodable, Sendable {
            public let id: String
            public let displayName: String
        }
    }
}
