//
//  APIClient.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

/// Protocol for sending API requests
public protocol APIClienting: Sendable {
    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response
}

// MARK: - Simple API Client (no auth)

/// Simple API client without authentication support
/// Use this for public endpoints or when auth is not needed
public final class APIClient: APIClienting, Sendable {
    private let baseURL: URL
    private let httpClient: HTTPClient

    public init(baseURL: URL, httpClient: HTTPClient = DefaultHTTPClient()) {
        self.baseURL = baseURL
        self.httpClient = httpClient
    }

    public func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        try await httpClient.send(endpoint, baseURL: baseURL)
    }
}

// MARK: - Authenticated API Client

/// API client with full authentication support
/// - Injects Bearer token for `.bearerToken` endpoints
/// - Handles 401 → refresh → retry automatically
extension AuthenticatingHTTPClient: APIClienting {
    // send() method is already implemented in AuthenticatingHTTPClient
}
