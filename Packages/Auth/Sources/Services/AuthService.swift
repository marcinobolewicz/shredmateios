import Foundation
import os.log

private let logger = Logger(subsystem: "com.shredmate.auth", category: "AuthService")

/// Protocol for AuthService abstraction (enables testing)
public protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> AuthResponse
    func register(email: String, password: String, name: String) async throws -> AuthResponse
    func logout() async throws
    func fetchCurrentUser() async throws -> User
    func refreshSession() async throws -> AuthResponse
    func isAuthenticated() async -> Bool
    func getAccessToken() async -> String?
}

/// Service handling authentication operations
public actor AuthService: AuthServiceProtocol {
    
    private let httpClient: AuthHTTPClient
    private let tokenStorage: TokenStorageProtocol
    
    public init(httpClient: AuthHTTPClient, tokenStorage: TokenStorageProtocol) {
        self.httpClient = httpClient
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Auth Operations
    
    public func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await httpClient.post("/auth/login", body: request)
        
        try await saveSession(from: response)
        return response
    }
    
    public func register(email: String, password: String, name: String) async throws -> AuthResponse {
        let request = RegisterRequest(email: email, password: password, name: name)
        let response: AuthResponse = try await httpClient.post("/auth/register", body: request)
        
        try await saveSession(from: response)
        return response
    }
    
    public func logout() async throws {
        if let tokens = await tokenStorage.loadTokens() {
            let request = LogoutRequest(refreshToken: tokens.refreshToken)
            try await httpClient.post("/auth/logout", body: request)
        }
        
        try await tokenStorage.clearAll()
    }
    
    public func fetchCurrentUser() async throws -> User {
        try await httpClient.get("/auth/me")
    }
    
    public func refreshSession() async throws -> AuthResponse {
        guard let tokens = await tokenStorage.loadTokens() else {
            throw AuthError.noRefreshToken
        }
        
        let request = RefreshRequest(refreshToken: tokens.refreshToken)
        let response: AuthResponse = try await httpClient.post("/auth/refresh", body: request)
        
        try await saveSession(from: response)
        return response
    }
    
    // MARK: - Session Helpers
    
    private func saveSession(from response: AuthResponse) async throws {
        let tokens = AuthTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        try await tokenStorage.saveTokens(tokens)
        try await tokenStorage.saveUser(response.user)
    }
    
    // MARK: - Token Access
    
    public func getAccessToken() async -> String? {
        await tokenStorage.loadTokens()?.accessToken
    }
    
    public func isAuthenticated() async -> Bool {
        await tokenStorage.loadTokens() != nil
    }
    
    public func getCurrentUser() async -> User? {
        await tokenStorage.loadUser()
    }
    
    public func getTokens() async -> AuthTokens? {
        await tokenStorage.loadTokens()
    }
}
