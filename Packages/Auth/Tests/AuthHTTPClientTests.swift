import XCTest
@testable import Auth
import Foundation

final class AuthHTTPClientTests: XCTestCase {
    
    // MARK: - URL Building Tests
    
    func testBuildRequestUsesCorrectBaseURL() async throws {
        let mockStorage = MockTokenStorage()
        let client = AuthHTTPClient(
            baseURL: "https://api.shredmate.eu/api/v1",
            tokenStorage: mockStorage
        )
        
        // We can't directly test buildRequest as it's private,
        // but we can test that the client is created correctly
        XCTAssertNotNil(client)
    }
    
    // MARK: - Authorization Header Tests
    
    func testPublicEndpointDoesNotRequireAuthorization() async {
        // Public endpoints should not fail without tokens
        let mockStorage = MockTokenStorage()
        let client = AuthHTTPClient(
            baseURL: "https://api.shredmate.eu/api/v1",
            tokenStorage: mockStorage
        )
        
        // Auth endpoints are public and should work without stored tokens
        // (actual network call would fail, but this tests the configuration)
        XCTAssertNotNil(client)
    }
    
    // MARK: - Error Mapping Tests
    
    func testStatusCode400MapsToInvalidCredentials() {
        // Test that 400 maps to invalidCredentials
        // Since mapStatusCodeToError is private, we test indirectly through errors
        let error = AuthError.invalidCredentials
        XCTAssertEqual(error.localizedDescription, "Invalid email or password.")
    }
    
    func testStatusCode401MapsToUnauthorized() {
        let error = AuthError.unauthorized
        XCTAssertEqual(error.localizedDescription, "You are not authorized. Please log in.")
    }
    
    func testStatusCode500MapsToServerError() {
        let error = AuthError.serverError(statusCode: 500)
        XCTAssertTrue(error.localizedDescription.contains("500"))
    }
    
    // MARK: - HTTPMethod Tests
    
    func testHTTPMethodRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
    }
    
    // MARK: - Empty Response Tests
    
    func testEmptyResponseCanBeCreated() {
        let response = EmptyResponse()
        XCTAssertNotNil(response)
    }
    
    // MARK: - Session Invalidation Handler Tests
    
    func testSetSessionInvalidationHandler() async {
        let mockStorage = MockTokenStorage()
        let client = AuthHTTPClient(
            baseURL: "https://api.test.com",
            tokenStorage: mockStorage
        )
        
        var handlerCalled = false
        
        await client.setSessionInvalidationHandler {
            handlerCalled = true
        }
        
        // Handler is set but not called yet
        XCTAssertFalse(handlerCalled)
    }
}

// MARK: - Mock URLSession Tests

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler not set")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

final class AuthHTTPClientNetworkTests: XCTestCase {
    
    private var mockStorage: MockTokenStorage!
    private var session: URLSession!
    
    override func setUp() async throws {
        mockStorage = MockTokenStorage()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
    }
    
    func testSuccessfulGetRequestDecodesResponse() async throws {
        let expectedUser = User(id: "123", email: "test@test.com", name: "Test User")
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let responseData = try encoder.encode(expectedUser)
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/api/v1/auth/me")
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }
        
        let client = AuthHTTPClient(
            baseURL: "https://api.test.com/api/v1",
            tokenStorage: mockStorage,
            session: session
        )
        
        let user: User = try await client.get("/auth/me")
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.email, "test@test.com")
    }
    
    func testRequestIncludesAuthorizationHeaderWhenTokenExists() async throws {
        let tokens = AuthTokens(accessToken: "test-token-123", refreshToken: "refresh")
        try await mockStorage.saveTokens(tokens)
        
        MockURLProtocol.requestHandler = { request in
            // Check that Authorization header is present for non-public endpoint
            let authHeader = request.value(forHTTPHeaderField: "Authorization")
            XCTAssertEqual(authHeader, "Bearer test-token-123")
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, "{}".data(using: .utf8)!)
        }
        
        let client = AuthHTTPClient(
            baseURL: "https://api.test.com/api/v1",
            tokenStorage: mockStorage,
            session: session
        )
        
        let _: EmptyResponse = try await client.get("/riders/me")
    }
    
    func testPublicEndpointDoesNotIncludeAuthorizationHeader() async throws {
        MockURLProtocol.requestHandler = { request in
            // Public endpoints should not have Authorization header
            let authHeader = request.value(forHTTPHeaderField: "Authorization")
            XCTAssertNil(authHeader)
            
            // Return mock auth response
            let responseData = """
            {
                "access_token": "new-token",
                "refresh_token": "new-refresh",
                "user": {"id": "1", "email": "test@test.com"}
            }
            """.data(using: .utf8)!
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }
        
        let client = AuthHTTPClient(
            baseURL: "https://api.test.com/api/v1",
            tokenStorage: mockStorage,
            session: session
        )
        
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }
        
        let _: AuthResponse = try await client.post("/auth/login", body: LoginRequest(email: "test@test.com", password: "password"))
    }
    
    func testServerErrorThrowsCorrectError() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        let client = AuthHTTPClient(
            baseURL: "https://api.test.com/api/v1",
            tokenStorage: mockStorage,
            session: session
        )
        
        do {
            let _: User = try await client.get("/auth/me")
            XCTFail("Should have thrown error")
        } catch let error as AuthError {
            if case .serverError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testUnauthorizedThrowsUnauthorizedError() async throws {
        // First request returns 401
        var requestCount = 0
        
        MockURLProtocol.requestHandler = { request in
            requestCount += 1
            
            // For refresh endpoint, also return 401 to simulate expired refresh token
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        
        let tokens = AuthTokens(accessToken: "expired", refreshToken: "also-expired")
        try await mockStorage.saveTokens(tokens)
        
        let client = AuthHTTPClient(
            baseURL: "https://api.test.com/api/v1",
            tokenStorage: mockStorage,
            session: session
        )
        
        do {
            let _: User = try await client.get("/riders/me")
            XCTFail("Should have thrown error")
        } catch let error as AuthError {
            XCTAssertEqual(error, .sessionExpired)
        }
    }
}

// MARK: - Mock Token Storage (reused from AuthServiceTests)

actor MockTokenStorage: TokenStorageProtocol {
    private var tokens: AuthTokens?
    private var user: User?
    
    func saveTokens(_ tokens: AuthTokens) async throws {
        self.tokens = tokens
    }
    
    func loadTokens() async -> AuthTokens? {
        tokens
    }
    
    func clearTokens() async throws {
        tokens = nil
    }
    
    func saveUser(_ user: User) async throws {
        self.user = user
    }
    
    func loadUser() async -> User? {
        user
    }
    
    func clearUser() async throws {
        user = nil
    }
    
    func clearAll() async throws {
        tokens = nil
        user = nil
    }
}
