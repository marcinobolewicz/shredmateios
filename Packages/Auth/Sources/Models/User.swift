import Foundation

/// User model returned from auth endpoints
public struct User: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let email: String
    public let name: String?
    public let createdAt: Date?
    
    public init(id: String, email: String, name: String? = nil, createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.createdAt = createdAt
    }
}
