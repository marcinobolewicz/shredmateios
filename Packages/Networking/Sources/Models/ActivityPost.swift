import Foundation

// MARK: - Activity Type

public enum ActivityType: String, Encodable, Sendable {
    case checkIn = "CHECKIN"
    case photo   = "PHOTO"
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

// MARK: - Response

public struct ActivityPost: Decodable, Sendable, Identifiable {
    public let id: String
    public let type: String
    public let placeId: String
    public let photoUrl: String?
    public let caption: String?
    public let taggedRiderIds: [String]
    public let createdAt: String
}
