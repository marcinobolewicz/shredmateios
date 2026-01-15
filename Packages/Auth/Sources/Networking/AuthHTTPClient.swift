import Foundation
import os.log

private let logger = Logger(subsystem: "com.shredmate.auth", category: "HTTPClient")

/// HTTP method enum
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Authenticated HTTP client with automatic token injection and 401 refresh handling
public actor AuthHTTPClient {
    
    private let baseURL: String
    private let session: URLSession
    private let tokenStorage: TokenStorageProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    /// Endpoints that don't require authorization header
    private let publicEndpoints = [
        "/auth/login",
        "/auth/register",
        "/auth/refresh"
    ]
    
    /// Single-flight refresh state
    private var isRefreshing = false
    private var refreshContinuations: [CheckedContinuation<AuthTokens, Error>] = []
    
    /// Callback when session is invalidated (refresh failed)
    public var onSessionInvalidated: (@Sendable () async -> Void)?
    
    public init(
        baseURL: String,
        tokenStorage: TokenStorageProtocol,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.tokenStorage = tokenStorage
        self.session = session
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    /// Set the session invalidation handler
    public func setSessionInvalidationHandler(_ handler: @escaping @Sendable () async -> Void) {
        onSessionInvalidated = handler
    }
    
    // MARK: - Public Request Methods
    
    /// Perform GET request
    public func get<T: Decodable>(_ endpoint: String) async throws -> T {
        try await request(endpoint, method: .get)
    }
    
    /// Perform POST request with body
    public func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await request(endpoint, method: .post, body: body)
    }
    
    /// Perform POST request without response body
    public func post<B: Encodable>(_ endpoint: String, body: B) async throws {
        let _: EmptyResponse = try await request(endpoint, method: .post, body: body)
    }
    
    /// Perform PUT request with body
    public func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await request(endpoint, method: .put, body: body)
    }
    
    /// Perform PATCH request with body
    public func patch<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await request(endpoint, method: .patch, body: body)
    }
    
    /// Perform DELETE request
    public func delete(_ endpoint: String) async throws {
        let _: EmptyResponse = try await request(endpoint, method: .delete)
    }
    
    /// Perform multipart file upload
    public func uploadMultipart<T: Decodable>(
        _ endpoint: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String = "file"
    ) async throws -> T {
        try await multipartRequest(
            endpoint,
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            fieldName: fieldName
        )
    }
    
    // MARK: - Core Request Logic
    
    private func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod,
        body: (any Encodable)? = nil,
        isRetry: Bool = false
    ) async throws -> T {
        logger.debug("➡️ \(method.rawValue) \(endpoint) (retry: \(isRetry))")
        
        let urlRequest = try await buildRequest(endpoint, method: method, body: body)
        
        let hasAuth = urlRequest.value(forHTTPHeaderField: "Authorization") != nil
        logger.debug("   Auth header: \(hasAuth ? "present" : "MISSING")")
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("❌ Invalid response type")
            throw AuthError.networkError("Invalid response type")
        }
        
        logger.debug("⬅️ \(httpResponse.statusCode) \(endpoint)")
        
        // Handle 401 - attempt refresh and retry
        if httpResponse.statusCode == 401 && !isRetry && !isPublicEndpoint(endpoint) {
            logger.warning("🔄 Got 401, attempting token refresh...")
            _ = try await performSingleFlightRefresh()
            return try await request(endpoint, method: method, body: body, isRetry: true)
        }
        
        // Handle other errors
        guard (200...299).contains(httpResponse.statusCode) else {
            let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
            logger.error("❌ Error \(httpResponse.statusCode): \(bodyStr)")
            throw mapStatusCodeToError(httpResponse.statusCode)
        }
        
        // Handle empty responses
        if T.self == EmptyResponse.self || data.isEmpty {
            guard let emptyResponse = EmptyResponse() as? T else {
                throw AuthError.decodingError
            }
            return emptyResponse
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError {
            let bodyStr = String(data: data, encoding: .utf8) ?? "<binary>"
            logger.error("❌ Decoding error: \(decodingError.localizedDescription)")
            logger.error("   Response body: \(bodyStr)")
            throw AuthError.decodingError
        }
    }
    
    private func buildRequest(
        _ endpoint: String,
        method: HTTPMethod,
        body: (any Encodable)? = nil
    ) async throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else {
            throw AuthError.networkError("Invalid URL: \(baseURL + endpoint)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header for protected endpoints
        if !isPublicEndpoint(endpoint) {
            guard let tokens = await tokenStorage.loadTokens() else {
                logger.error("🔐 No tokens found for protected endpoint: \(endpoint)")
                throw AuthError.noRefreshToken
            }
            logger.debug("🔐 Token loaded, first 20 chars: \(String(tokens.accessToken.prefix(20)))...")
            request.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode body
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        
        return request
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
            let tokens = try await executeRefresh()
            
            // Notify all waiting continuations
            let continuations = refreshContinuations
            refreshContinuations = []
            isRefreshing = false
            
            for continuation in continuations {
                continuation.resume(returning: tokens)
            }
            
            return tokens
        } catch {
            // Notify all waiting continuations of failure
            let continuations = refreshContinuations
            refreshContinuations = []
            isRefreshing = false
            
            for continuation in continuations {
                continuation.resume(throwing: error)
            }
            
            // Invalidate session on refresh failure
            await onSessionInvalidated?()
            
            throw error
        }
    }
    
    private func executeRefresh() async throws -> AuthTokens {
        guard let currentTokens = await tokenStorage.loadTokens() else {
            throw AuthError.noRefreshToken
        }
        
        let refreshBody = RefreshRequest(refreshToken: currentTokens.refreshToken)
        
        guard let url = URL(string: baseURL + "/auth/refresh") else {
            throw AuthError.networkError("Invalid refresh URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(refreshBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response")
        }
        
        // Refresh token expired or invalid
        if httpResponse.statusCode == 401 {
            throw AuthError.sessionExpired
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.refreshFailed
        }
        
        let authResponse = try decoder.decode(AuthResponse.self, from: data)
        let newTokens = AuthTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken
        )
        
        try await tokenStorage.saveTokens(newTokens)
        try await tokenStorage.saveUser(authResponse.user)
        
        return newTokens
    }
    
    // MARK: - Multipart Upload
    
    private func multipartRequest<T: Decodable>(
        _ endpoint: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw AuthError.networkError("Invalid URL: \(baseURL + endpoint)")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        if let tokens = await tokenStorage.loadTokens() {
            request.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Build multipart body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response type")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw mapStatusCodeToError(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AuthError.decodingError
        }
    }
    
    // MARK: - Helpers
    
    private func isPublicEndpoint(_ endpoint: String) -> Bool {
        publicEndpoints.contains { endpoint.hasPrefix($0) }
    }
    
    private func mapStatusCodeToError(_ statusCode: Int) -> AuthError {
        switch statusCode {
        case 400:
            return .invalidCredentials
        case 401:
            return .unauthorized
        case 403:
            return .unauthorized
        default:
            return .serverError(statusCode: statusCode)
        }
    }
}

/// Helper type for endpoints that return empty response
public struct EmptyResponse: Decodable, Sendable {
    public init() {}
}
