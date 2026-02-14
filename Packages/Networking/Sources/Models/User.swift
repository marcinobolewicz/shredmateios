import Foundation

/// User role enum
public enum UserRole: String, Codable, Sendable {
    case user = "USER"
    case editor = "EDITOR"
    case admin = "ADMIN"
}

public struct User: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let email: String
    public let role: UserRole?
    public let name: String?
    public let createdAt: Date?

    public init(
        id: String,
        email: String,
        role: UserRole? = nil,
        name: String? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.role = role
        self.name = name
        self.createdAt = createdAt
    }

    // MARK: - Decoding (id | userId)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id =
            try container.decodeIfPresent(String.self, forKey: .id)
            ?? container.decode(String.self, forKey: .userId)

        self.email = try container.decode(String.self, forKey: .email)
        self.role = try container.decodeIfPresent(UserRole.self, forKey: .role)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    // MARK: - Encoding (always "id")

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(role, forKey: .role)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case email
        case role
        case name
        case createdAt
    }
}
