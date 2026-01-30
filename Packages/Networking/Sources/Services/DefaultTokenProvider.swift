//
//  DefaultTokenProvider.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation
import os.log

private let logger = Logger(subsystem: "com.shredmate.auth", category: "TokenProvider")

/// Default implementation of TokenProvider using TokenStorage and a simple HTTP client for refresh
public actor DefaultTokenProvider: TokenProvider {
    
    private let tokenStorage: TokenStorageProtocol
    private let refreshClient: APIClienting
    
    /// Creates a TokenProvider with storage and a client for refresh requests
    /// - Parameters:
    ///   - tokenStorage: Storage for tokens
    ///   - refreshClient: Client for refresh requests (should NOT have auth, as refresh doesn't need Bearer)
    public init(tokenStorage: TokenStorageProtocol, refreshClient: APIClienting) {
        self.tokenStorage = tokenStorage
        self.refreshClient = refreshClient
    }
    
    /// Convenience initializer with base URL
    public init(tokenStorage: TokenStorageProtocol, baseURL: URL) {
        self.tokenStorage = tokenStorage
        self.refreshClient = APIClient(baseURL: baseURL)
    }
    
    // MARK: - TokenProvider
    
    public func getAccessToken() async -> String? {
        await tokenStorage.loadTokens()?.accessToken
    }
    
    public func refreshTokens() async throws -> AuthTokens {
        guard let currentTokens = await tokenStorage.loadTokens() else {
            logger.error("No refresh token available")
            throw NetworkError.unauthorized
        }
        
        logger.debug("Attempting token refresh")
        
        let response = try await refreshClient.send(
            AuthAPI.refresh(refreshToken: currentTokens.refreshToken)
        )
        
        let newTokens = AuthTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        try await tokenStorage.saveTokens(newTokens)
        try await tokenStorage.saveUser(response.user)
        
        logger.debug("Token refresh successful")
        return newTokens
    }
}
