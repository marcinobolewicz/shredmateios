import Foundation

/// Rider type enum
public enum RiderType: String, Codable, Sendable, CaseIterable {
    case rider = "RIDER"
    case mentor = "MENTOR"
    case both = "BOTH"
    
    public var displayName: String {
        switch self {
        case .rider: return "Rider"
        case .mentor: return "Mentor"
        case .both: return "Rider & Mentor"
        }
    }
}

/// Rider profile model
public struct Rider: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let userId: String
    public let type: RiderType?
    public let displayName: String?
    public let description: String?
    public let avatarUrl: String?
    public let isPublic: Bool?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        id: String,
        userId: String,
        type: RiderType? = nil,
        displayName: String? = nil,
        description: String? = nil,
        avatarUrl: String? = nil,
        isPublic: Bool? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.displayName = displayName
        self.description = description
        self.avatarUrl = avatarUrl
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Request body for updating rider profile
public struct UpdateRiderRequest: Codable, Sendable {
    public let type: RiderType?
    public let displayName: String?
    public let avatarUrl: String?
    public let description: String?
    public let isPublic: Bool?
    
    public init(
        type: RiderType? = nil,
        displayName: String? = nil,
        avatarUrl: String? = nil,
        description: String? = nil,
        isPublic: Bool? = nil
    ) {
        self.type = type
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.description = description
        self.isPublic = isPublic
    }
}

// MARK: - Base Location

/// Rider's base location
public struct RiderBaseLocation: Codable, Sendable, Equatable {
    public let latitude: Double
    public let longitude: Double
    public let name: String?
    
    public init(latitude: Double, longitude: Double, name: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
}

/// Request for updating base location
public struct UpdateBaseLocationRequest: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public let name: String?
    
    public init(latitude: Double, longitude: Double, name: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
}

// MARK: - Sports

/// Sport definition
public struct Sport: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let name: String
    public let slug: String
    public let createdByUserId: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        id: UUID,
        name: String,
        slug: String,
        createdByUserId: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.createdByUserId = createdByUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Skill level for a sport
public enum SkillLevel: String, Codable, Sendable, CaseIterable {
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"
    case expert = "EXPERT"
    
    public var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
}

/// Rider's sport with level and mentor status
public struct RiderSport: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let sportId: String
    public let sport: Sport?
    public let level: SkillLevel
    public let isMentor: Bool
    
    public init(
        id: String,
        sportId: String,
        sport: Sport? = nil,
        level: SkillLevel,
        isMentor: Bool = false
    ) {
        self.id = id
        self.sportId = sportId
        self.sport = sport
        self.level = level
        self.isMentor = isMentor
    }
}

/// Request for upserting rider sport
public struct UpsertRiderSportRequest: Codable, Sendable {
    public let level: SkillLevel
    public let isMentor: Bool
    
    public init(level: SkillLevel, isMentor: Bool = false) {
        self.level = level
        self.isMentor = isMentor
    }
}

/// Avatar upload response
public struct AvatarUploadResponse: Codable, Sendable {
    public let avatarUrl: String
}
