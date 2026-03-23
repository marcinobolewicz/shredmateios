import Foundation

// MARK: - Activity Type

public enum ActivityType: String, Encodable, Sendable {
    case checkIn = "CHECKIN"
    case photo   = "PHOTO"
}

// MARK: - Photo Upload

public struct ActivityPhotoUploadResponse: Decodable, Sendable {
    public let photoUrl: String

    enum CodingKeys: String, CodingKey {
        case photoUrl = "url"
    }
}

// MARK: - Request

public struct CreateActivityRequest: Encodable, Sendable {
    public let type: ActivityType
    public let placeId: String
    public let photoUrl: String?
    public let caption: String?
    public let taggedRiderIds: [String]

    public init(
        type: ActivityType = .checkIn,
        placeId: String,
        photoUrl: String? = nil,
        caption: String? = nil,
        taggedRiderIds: [String] = []
    ) {
        self.type = type
        self.placeId = placeId
        self.photoUrl = photoUrl
        self.caption = caption
        self.taggedRiderIds = taggedRiderIds
    }
}

// MARK: - Paginated envelope

public struct PaginatedResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let items: [T]
    public let total: Int
    public let page: Int
    public let limit: Int
}

// MARK: - Response

public struct ActivityPostPlace: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let avatarUrl: String?
}

public struct ActivityPostRider: Decodable, Sendable, Identifiable, Hashable {
    public let id: String
    public let displayName: String
    public let avatarUrl: String?

    public var initials: String {
        let parts = displayName.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
    }
}

public struct ActivityPost: Decodable, Sendable, Identifiable {
    public let id: String
    public let type: String
    public let placeId: String
    public let photoUrl: String?
    public let caption: String?
    public let createdAt: String
    public let place: ActivityPostPlace
    public let rider: ActivityPostRider
    public let taggedRiders: [ActivityPostRider]
}
