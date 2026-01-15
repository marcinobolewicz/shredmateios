import XCTest
@testable import Auth

final class AuthServiceTests: XCTestCase {
    
    private var mockStorage: MockTokenStorage!
    private var authService: AuthService!
    
    override func setUp() async throws {
        mockStorage = MockTokenStorage()
        // Note: In real tests, you'd use a mock HTTP client
        // This is a basic structure test
    }
    
    func testIsAuthenticatedReturnsFalseWhenNoTokens() async {
        let storage = MockTokenStorage()
        let httpClient = AuthHTTPClient(
            baseURL: "https://api.test.com",
            tokenStorage: storage
        )
        let service = AuthService(httpClient: httpClient, tokenStorage: storage)
        
        let isAuthenticated = await service.isAuthenticated()
        XCTAssertFalse(isAuthenticated)
    }
    
    func testIsAuthenticatedReturnsTrueWhenTokensExist() async throws {
        let storage = MockTokenStorage()
        let tokens = AuthTokens(accessToken: "test-access", refreshToken: "test-refresh")
        try await storage.saveTokens(tokens)
        
        let httpClient = AuthHTTPClient(
            baseURL: "https://api.test.com",
            tokenStorage: storage
        )
        let service = AuthService(httpClient: httpClient, tokenStorage: storage)
        
        let isAuthenticated = await service.isAuthenticated()
        XCTAssertTrue(isAuthenticated)
    }
    
    func testGetAccessTokenReturnsNilWhenNoTokens() async {
        let storage = MockTokenStorage()
        let httpClient = AuthHTTPClient(
            baseURL: "https://api.test.com",
            tokenStorage: storage
        )
        let service = AuthService(httpClient: httpClient, tokenStorage: storage)
        
        let token = await service.getAccessToken()
        XCTAssertNil(token)
    }
    
    func testGetAccessTokenReturnsTokenWhenExists() async throws {
        let storage = MockTokenStorage()
        let tokens = AuthTokens(accessToken: "my-token", refreshToken: "refresh")
        try await storage.saveTokens(tokens)
        
        let httpClient = AuthHTTPClient(
            baseURL: "https://api.test.com",
            tokenStorage: storage
        )
        let service = AuthService(httpClient: httpClient, tokenStorage: storage)
        
        let token = await service.getAccessToken()
        XCTAssertEqual(token, "my-token")
    }
}

// MARK: - Mock Token Storage

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
