//
//  AuthService.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

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
    func getTokens() async -> AuthTokens?
}

/// Service handling authentication operations
public actor AuthService: AuthServiceProtocol {
    
    private let client: APIClienting
    private let tokenStorage: TokenStorageProtocol
    
    public init(client: APIClienting, tokenStorage: TokenStorageProtocol) {
        self.client = client
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Auth Operations
    
    public func login(email: String, password: String) async throws -> AuthResponse {
        logger.debug("Attempting login for: \(email)")
        let response = try await client.send(AuthAPI.login(email: email, password: password))
        try await saveSession(from: response)
        logger.debug("Login successful")
        return response
    }
    
    public func register(email: String, password: String, name: String) async throws -> AuthResponse {
        logger.debug("Attempting registration for: \(email)")
        let response = try await client.send(AuthAPI.register(email: email, password: password, name: name))
        try await saveSession(from: response)
        logger.debug("Registration successful")
        return response
    }
    
    public func logout() async throws {
        logger.debug("Logging out")
        if let tokens = await tokenStorage.loadTokens() {
            _ = try await client.send(AuthAPI.logout(refreshToken: tokens.refreshToken))
        }
        try await tokenStorage.clearAll()
        logger.debug("Logout complete")
    }
    
    public func fetchCurrentUser() async throws -> User {
        try await client.send(AuthAPI.me())
    }
    
    public func refreshSession() async throws -> AuthResponse {
        guard let tokens = await tokenStorage.loadTokens() else {
            throw AuthError.noRefreshToken
        }
        
        logger.debug("Refreshing session")
        let response = try await client.send(AuthAPI.refresh(refreshToken: tokens.refreshToken))
        try await saveSession(from: response)
        logger.debug("Session refreshed")
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
