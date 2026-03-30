import Foundation

public struct MentorListItem: Decodable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let displayName: String?
    public let description: String?
    public let avatarUrl: String?
    public let recommendationCount: Int
    public let sessionCount: Int
    public let currentPlace: MentorCurrentPlace?
    public let riderSports: [MentorRiderSport]
}

public struct MentorCurrentPlace: Decodable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let avatarUrl: String?
    public let lastSeenAt: Date?
    public let sport: MentorSportSummary
}

public struct MentorRiderSport: Decodable, Sendable, Equatable {
    public let level: SkillLevel
    public let sport: MentorSportSummary
}

public struct MentorSportSummary: Decodable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let slug: String
}
