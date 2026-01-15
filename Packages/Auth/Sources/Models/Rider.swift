import Foundation

/// Rider type enum
public enum RiderType: String, Codable, Sendable {
    case rider = "RIDER"
    case mentor = "MENTOR"
    case both = "BOTH"
}

/// Rider profile model
public struct Rider: Codable, Sendable, Equatable {
    public let userId: String
    public let type: RiderType
    public let description: String?
    public let avatarUrl: String?
    
    public init(
        userId: String,
        type: RiderType,
        description: String? = nil,
        avatarUrl: String? = nil
    ) {
        self.userId = userId
        self.type = type
        self.description = description
        self.avatarUrl = avatarUrl
    }
}

/// Request body for updating rider profile
public struct UpdateRiderRequest: Codable, Sendable {
    public let type: RiderType?
    public let description: String?
    public let avatarUrl: String?
    
    public init(type: RiderType? = nil, description: String? = nil, avatarUrl: String? = nil) {
        self.type = type
        self.description = description
        self.avatarUrl = avatarUrl
    }
}
