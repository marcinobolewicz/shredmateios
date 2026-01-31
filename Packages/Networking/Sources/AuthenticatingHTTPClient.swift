//
//  AuthenticatingHTTPClient.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation
import os.log

private let logger = Logger(subsystem: "com.shredmate.networking", category: "AuthHTTPClient")

/// HTTP client that handles authentication automatically
/// - Injects Bearer token for endpoints requiring auth
/// - Handles 401 responses with automatic token refresh and retry
/// - Uses single-flight pattern for concurrent refresh requests
public actor AuthenticatingHTTPClient {
    private let baseURL: URL
    private let session: NetworkSessioning
    private let coding: JSONCoding
    private let requestBuilder: RequestBuilding
    private let tokenProvider: TokenProvider
    
    /// Single-flight refresh state
    private var isRefreshing = false
    private var refreshContinuations: [CheckedContinuation<AuthTokens, Error>] = []
    
    /// Callback when session is invalidated (refresh failed)
    public var onSessionInvalidated: (@Sendable () async -> Void)?
    
    public init(
        baseURL: URL,
        tokenProvider: TokenProvider,
        session: NetworkSessioning = URLSession.shared,
        coding: JSONCoding = DefaultJSONCoding(),
        requestBuilder: RequestBuilding? = nil
    ) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.session = session
        self.coding = coding
        self.requestBuilder = requestBuilder ?? DefaultRequestBuilder(coding: coding)
    }
    
    /// Set the session invalidation handler
    public func setSessionInvalidationHandler(_ handler: @escaping @Sendable () async -> Void) {
        onSessionInvalidated = handler
    }
    
    // MARK: - Public API
    
    /// Send an endpoint request with automatic auth handling
    public func send<Response: Decodable & Sendable>(
        _ endpoint: Endpoint<Response>
    ) async throws -> Response {
        try await performRequest(endpoint, isRetry: false)
    }
    
    // MARK: - Core Request Logic
    
    private func performRequest<Response: Decodable & Sendable>(
        _ endpoint: Endpoint<Response>,
        isRetry: Bool
    ) async throws -> Response {
        var request = try requestBuilder.makeRequest(baseURL: baseURL, endpoint: endpoint)
        
        // Inject authorization header if required
        if endpoint.auth == .bearerToken {
            guard let token = await tokenProvider.getAccessToken() else {
                logger.error("🔐 No access token for authenticated endpoint: \(endpoint.path)")
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            logger.debug("🔐 Token injected for: \(endpoint.path)")
        }
        
        logger.debug("➡️ \(endpoint.method.rawValue) \(endpoint.path) (retry: \(isRetry))")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response type")
        }
        
        logger.debug("⬅️ \(httpResponse.statusCode) \(endpoint.path)")
        
        // Handle 401 - attempt refresh and retry (only for authenticated endpoints)
        if httpResponse.statusCode == 401 && !isRetry && endpoint.auth == .bearerToken {
            logger.warning("🔄 Got 401, attempting token refresh...")
            _ = try await performSingleFlightRefresh()
            return try await performRequest(endpoint, isRetry: true)
        }
        
        // Handle errors
        guard (200...299).contains(httpResponse.statusCode) else {
            let bodyStr = String(decoding: data, as: UTF8.self)
            logger.error("❌ Error \(httpResponse.statusCode): \(bodyStr)")
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        // Handle empty responses
        if Response.self == EmptyResponse.self || data.isEmpty {
            if let emptyResponse = EmptyResponse() as? Response {
                return emptyResponse
            }
            throw NetworkError.noData
        }
        
        do {
            return try coding.makeDecoder().decode(Response.self, from: data)
        } catch let decodingError as DecodingError {
            let bodyStr = String(decoding: data, as: UTF8.self)
            
            switch decodingError {
            case .keyNotFound(let key, let context):
                logger.error("❌ Decoding error: Missing key '\(key.stringValue)' at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
            case .typeMismatch(let type, let context):
                logger.error("❌ Decoding error: Type mismatch for \(type) at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
            case .valueNotFound(let type, let context):
                logger.error("❌ Decoding error: Value not found for \(type) at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
            case .dataCorrupted(let context):
                logger.error("❌ Decoding error: Data corrupted at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
            @unknown default:
                logger.error("❌ Decoding error: \(decodingError.localizedDescription)")
            }
            
            logger.error("   Response body: \(bodyStr)")
            throw NetworkError.decodingFailed
        } catch {
            let bodyStr = String(decoding: data, as: UTF8.self)
            logger.error("❌ Decoding error: \(error.localizedDescription)")
            logger.error("   Response body: \(bodyStr)")
            throw NetworkError.decodingFailed
        }
    }
    
    // MARK: - Single-Flight Refresh
    
    private func performSingleFlightRefresh() async throws -> AuthTokens {
        // If already refreshing, wait for the result
        if isRefreshing {
            return try await withCheckedThrowingContinuation { continuation in
                refreshContinuations.append(continuation)
            }
        }
        
        isRefreshing = true
        
        do {
            let tokens = try await tokenProvider.refreshTokens()
            
            // Notify all waiting continuations
            let continuations = refreshContinuations
            refreshContinuations = []
            isRefreshing = false
            
            for continuation in continuations {
                continuation.resume(returning: tokens)
            }
            
            logger.debug("✅ Token refresh successful")
            return tokens
        } catch {
            // Notify all waiting continuations of failure
            let continuations = refreshContinuations
            refreshContinuations = []
            isRefreshing = false
            
            for continuation in continuations {
                continuation.resume(throwing: error)
            }
            
            logger.error("❌ Token refresh failed: \(error.localizedDescription)")
            
            // Invalidate session on refresh failure
            await onSessionInvalidated?()
            
            throw error
        }
    }
}
