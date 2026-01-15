import Foundation

/// Login request body
public struct LoginRequest: Codable, Sendable {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// Register request body
public struct RegisterRequest: Codable, Sendable {
    public let email: String
    public let password: String
    public let name: String
    
    public init(email: String, password: String, name: String) {
        self.email = email
        self.password = password
        self.name = name
    }
}

/// Refresh token request body
public struct RefreshRequest: Codable, Sendable {
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

/// Logout request body
public struct LogoutRequest: Codable, Sendable {
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
