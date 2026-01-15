import Foundation
import Security

/// Protocol for token storage abstraction (enables testing)
public protocol TokenStorageProtocol: Sendable {
    func saveTokens(_ tokens: AuthTokens) async throws
    func loadTokens() async -> AuthTokens?
    func clearTokens() async throws
    func saveUser(_ user: User) async throws
    func loadUser() async -> User?
    func clearUser() async throws
    func clearAll() async throws
}

/// Keychain-based secure token storage
public actor TokenStorage: TokenStorageProtocol {
    
    private let service: String
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let expiresAtKey = "expiresAt"
    private let userKey = "currentUser"
    
    public init(service: String = "com.shredmate.auth") {
        self.service = service
    }
    
    // MARK: - Tokens
    
    public func saveTokens(_ tokens: AuthTokens) async throws {
        guard let accessData = tokens.accessToken.data(using: .utf8),
              let refreshData = tokens.refreshToken.data(using: .utf8) else {
            throw AuthError.tokenStorageError("Failed to encode tokens")
        }
        
        try saveToKeychain(key: accessTokenKey, data: accessData)
        try saveToKeychain(key: refreshTokenKey, data: refreshData)
        
        if let expiresAt = tokens.expiresAt {
            let timestamp = String(expiresAt.timeIntervalSince1970)
            if let timestampData = timestamp.data(using: .utf8) {
                try saveToKeychain(key: expiresAtKey, data: timestampData)
            }
        }
    }
    
    public func loadTokens() async -> AuthTokens? {
        guard let accessData = loadFromKeychain(key: accessTokenKey),
              let refreshData = loadFromKeychain(key: refreshTokenKey) else {
            return nil
        }
        
        let accessToken = String(decoding: accessData, as: UTF8.self)
        let refreshToken = String(decoding: refreshData, as: UTF8.self)
        
        guard !accessToken.isEmpty, !refreshToken.isEmpty else {
            return nil
        }
        
        var expiresAt: Date?
        if let expiresData = loadFromKeychain(key: expiresAtKey) {
            let timestampStr = String(decoding: expiresData, as: UTF8.self)
            if let timestamp = Double(timestampStr) {
                expiresAt = Date(timeIntervalSince1970: timestamp)
            }
        }
        
        return AuthTokens(accessToken: accessToken, refreshToken: refreshToken, expiresAt: expiresAt)
    }
    
    public func clearTokens() async throws {
        try deleteFromKeychain(key: accessTokenKey)
        try deleteFromKeychain(key: refreshTokenKey)
        try deleteFromKeychain(key: expiresAtKey)
    }
    
    // MARK: - User
    
    public func saveUser(_ user: User) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        try saveToKeychain(key: userKey, data: data)
    }
    
    public func loadUser() async -> User? {
        guard let data = loadFromKeychain(key: userKey) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(User.self, from: data)
    }
    
    public func clearUser() async throws {
        try deleteFromKeychain(key: userKey)
    }
    
    // MARK: - Clear All
    
    public func clearAll() async throws {
        try await clearTokens()
        try await clearUser()
    }
    
    // MARK: - Keychain Operations
    
    private func saveToKeychain(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        var newItem = query
        newItem[kSecValueData as String] = data
        newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        
        let status = SecItemAdd(newItem as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AuthError.tokenStorageError("Failed to save to keychain: \(status)")
        }
    }
    
    private func loadFromKeychain(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    private func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AuthError.tokenStorageError("Failed to delete from keychain: \(status)")
        }
    }
}
