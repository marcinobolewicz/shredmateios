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
    public let id: UUID
    public let userId: String
    public let type: RiderType?
    public let displayName: String?
    public let description: String?
    public let avatarUrl: String?
    public let isPublic: Bool?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        id: UUID,
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
    public let updatedAt: Date?

    public init(latitude: Double, longitude: Double, updatedAt: Date? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.updatedAt = updatedAt
    }

    // Response shape: { "baseLocation": { "lat": ..., "lng": ... }, "baseLocationUpdatedAt": "..." }
    public init(from decoder: Decoder) throws {
        enum TopKeys: String, CodingKey { case baseLocation, baseLocationUpdatedAt }
        enum LocKeys: String, CodingKey { case lat, lng }

        let top = try decoder.container(keyedBy: TopKeys.self)
        let loc = try top.nestedContainer(keyedBy: LocKeys.self, forKey: .baseLocation)
        self.latitude = try loc.decode(Double.self, forKey: .lat)
        self.longitude = try loc.decode(Double.self, forKey: .lng)
        self.updatedAt = try top.decodeIfPresent(Date.self, forKey: .baseLocationUpdatedAt)
    }

    public func encode(to encoder: Encoder) throws {
        enum TopKeys: String, CodingKey { case baseLocation, baseLocationUpdatedAt }
        enum LocKeys: String, CodingKey { case lat, lng }

        var top = encoder.container(keyedBy: TopKeys.self)
        var loc = top.nestedContainer(keyedBy: LocKeys.self, forKey: .baseLocation)
        try loc.encode(latitude, forKey: .lat)
        try loc.encode(longitude, forKey: .lng)
        try top.encodeIfPresent(updatedAt, forKey: .baseLocationUpdatedAt)
    }
}

/// Request for updating base location
public struct UpdateBaseLocationRequest: Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct UpdateBaseLocationRequestDTO: Encodable, Sendable {
    let baseLocation: BaseLocationDTO

    init(request: UpdateBaseLocationRequest) {
        self.baseLocation = BaseLocationDTO(
            lat: request.latitude,
            lng: request.longitude
        )
    }
}

struct BaseLocationDTO: Encodable, Sendable {
    let lat: Double
    let lng: Double
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
    case casual = "CASUAL"
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"
    case expert = "EXPERT"

    public var displayName: String {
        switch self {
        case .casual: return "Casual"
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sportId = try container.decode(String.self, forKey: .sportId)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? sportId
        self.sport = try container.decodeIfPresent(Sport.self, forKey: .sport)
        self.level = try container.decode(SkillLevel.self, forKey: .level)
        self.isMentor = try container.decodeIfPresent(Bool.self, forKey: .isMentor) ?? false
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

// MARK: - Follow

public struct FollowedRider: Decodable, Sendable, Identifiable {
    public let id: String
    public let displayName: String?
    public let avatarUrl: String?

    private enum WrapperKeys: String, CodingKey { case following }
    private enum RiderKeys: String, CodingKey { case id, displayName, avatarUrl }

    public init(from decoder: Decoder) throws {
        // API wraps each entry: { "following": { "id", "displayName", "avatarUrl" } }
        if let wrapper = try? decoder.container(keyedBy: WrapperKeys.self),
           wrapper.contains(.following) {
            let nested = try wrapper.nestedContainer(keyedBy: RiderKeys.self, forKey: .following)
            self.id = try nested.decode(String.self, forKey: .id)
            self.displayName = try nested.decodeIfPresent(String.self, forKey: .displayName)
            self.avatarUrl = try nested.decodeIfPresent(String.self, forKey: .avatarUrl)
        } else {
            let container = try decoder.container(keyedBy: RiderKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
            self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        }
    }
}
