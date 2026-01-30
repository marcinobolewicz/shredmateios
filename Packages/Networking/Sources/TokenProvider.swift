//
//  TokenProvider.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

/// Protocol for providing and refreshing authentication tokens
public protocol TokenProvider: Sendable {
    /// Returns the current access token, or nil if not authenticated
    func getAccessToken() async -> String?
    
    /// Refreshes the session and returns new tokens
    /// Throws if refresh fails (e.g., refresh token expired)
    func refreshTokens() async throws -> AuthTokens
}
