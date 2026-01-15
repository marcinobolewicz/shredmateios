import XCTest
@testable import Auth

final class TokenStorageTests: XCTestCase {
    
    private var storage: MockTokenStorage!
    
    override func setUp() async throws {
        storage = MockTokenStorage()
    }
    
    func testLoadTokensReturnsNilWhenEmpty() async {
        let loaded = await storage.loadTokens()
        XCTAssertNil(loaded)
    }
    
    func testSaveAndLoadTokensRoundtrip() async throws {
        let tokens = AuthTokens(
            accessToken: "access123",
            refreshToken: "refresh456",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        try await storage.saveTokens(tokens)
        let loaded = await storage.loadTokens()
        
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.accessToken, "access123")
        XCTAssertEqual(loaded?.refreshToken, "refresh456")
    }
    
    func testClearTokensRemovesData() async throws {
        let tokens = AuthTokens(accessToken: "access", refreshToken: "refresh")
        try await storage.saveTokens(tokens)
        
        try await storage.clearTokens()
        
        XCTAssertNil(await storage.loadTokens())
    }
    
    func testClearAllRemovesBothTokensAndUser() async throws {
        try await storage.saveTokens(AuthTokens(accessToken: "a", refreshToken: "r"))
        try await storage.saveUser(User(id: "1", email: "test@test.com"))
        
        try await storage.clearAll()
        
        XCTAssertNil(await storage.loadTokens())
        XCTAssertNil(await storage.loadUser())
    }
}

