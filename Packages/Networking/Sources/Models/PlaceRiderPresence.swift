import Foundation

public struct PlaceRiderPresence: Decodable, Sendable, Equatable, Identifiable {
    public let placeId: UUID
    public let sportId: UUID
    public let role: PlaceRiderRole?
    public let rating: Double?
    public let lastSeenAt: Date?
    public let rider: PlaceRiderSummary
    public let sport: PlaceRiderSportSummary

    public var id: String {
        "\(rider.id.uuidString)-\(sportId.uuidString)"
    }
}

public struct PlaceRiderSummary: Decodable, Sendable, Equatable {
    public let id: UUID
    public let userId: UUID
    public let displayName: String?
    public let avatarUrl: String?
    public let baseLocation: PlaceRiderBaseLocation?
}

public struct PlaceRiderBaseLocation: Decodable, Sendable, Equatable {
    public let lat: Double
    public let lng: Double
}

public struct PlaceRiderSportSummary: Decodable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let slug: String
}
