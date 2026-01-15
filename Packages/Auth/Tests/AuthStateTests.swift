import XCTest
@testable import Auth

@MainActor
final class AuthStateTests: XCTestCase {
    
    private var mockStorage: MockTokenStorage!
    private var mockAuthService: MockAuthService!
    private var mockRiderService: MockRiderService!
    private var authState: AuthState!
    
    override func setUp() async throws {
        mockStorage = MockTokenStorage()
        mockAuthService = MockAuthService()
        mockRiderService = MockRiderService()
        
        authState = AuthState(
            authService: mockAuthService,
            riderService: mockRiderService,
            tokenStorage: mockStorage
        )
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateIsLoggedOut() {
        XCTAssertFalse(authState.isLoggedIn)
        XCTAssertNil(authState.user)
        XCTAssertNil(authState.rider)
        XCTAssertNil(authState.error)
        XCTAssertFalse(authState.isLoading)
    }
    
    func testIsLoggedInReturnsTrueWhenUserExists() async {
        let user = User(id: "1", email: "test@test.com")
        mockAuthService.mockUser = user
        
        await authState.login(email: "test@test.com", password: "password")
        
        XCTAssertTrue(authState.isLoggedIn)
        XCTAssertNotNil(authState.user)
    }
    
    // MARK: - Login Tests
    
    func testLoginSetsUserOnSuccess() async {
        let expectedUser = User(id: "123", email: "user@test.com", name: "Test")
        mockAuthService.mockUser = expectedUser
        
        await authState.login(email: "user@test.com", password: "password123")
        
        XCTAssertEqual(authState.user?.id, "123")
        XCTAssertEqual(authState.user?.email, "user@test.com")
        XCTAssertFalse(authState.isLoading)
    }
    
    func testLoginSetsErrorOnFailure() async {
        mockAuthService.shouldFail = true
        mockAuthService.errorToThrow = .invalidCredentials
        
        await authState.login(email: "wrong@test.com", password: "wrong")
        
        XCTAssertNil(authState.user)
        XCTAssertNotNil(authState.error)
        XCTAssertEqual(authState.error, .invalidCredentials)
    }
    
    func testLoginFetchesRiderProfileOnSuccess() async {
        let user = User(id: "1", email: "test@test.com")
        let rider = Rider(id: "r1", userId: "1", type: .rider, createdAt: Date(), updatedAt: Date())
        mockAuthService.mockUser = user
        mockRiderService.mockRider = rider
        
        await authState.login(email: "test@test.com", password: "password")
        
        XCTAssertNotNil(authState.rider)
        XCTAssertEqual(authState.rider?.id, "r1")
    }
    
    // MARK: - Register Tests
    
    func testRegisterSetsUserOnSuccess() async {
        let expectedUser = User(id: "new-user", email: "new@test.com", name: "New User")
        mockAuthService.mockUser = expectedUser
        
        await authState.register(email: "new@test.com", password: "password", name: "New User")
        
        XCTAssertEqual(authState.user?.id, "new-user")
        XCTAssertTrue(authState.isLoggedIn)
    }
    
    func testRegisterSetsErrorOnFailure() async {
        mockAuthService.shouldFail = true
        mockAuthService.errorToThrow = .serverError(statusCode: 422)
        
        await authState.register(email: "exists@test.com", password: "password", name: "Name")
        
        XCTAssertNil(authState.user)
        XCTAssertNotNil(authState.error)
    }
    
    // MARK: - Logout Tests
    
    func testLogoutClearsUserAndRider() async {
        // First login
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        mockRiderService.mockRider = Rider(id: "r1", userId: "1", type: .rider, createdAt: Date(), updatedAt: Date())
        await authState.login(email: "test@test.com", password: "password")
        
        XCTAssertTrue(authState.isLoggedIn)
        
        // Then logout
        await authState.logout()
        
        XCTAssertFalse(authState.isLoggedIn)
        XCTAssertNil(authState.user)
        XCTAssertNil(authState.rider)
    }
    
    func testLogoutClearsError() async {
        mockAuthService.shouldFail = true
        mockAuthService.errorToThrow = .invalidCredentials
        await authState.login(email: "test@test.com", password: "wrong")
        
        XCTAssertNotNil(authState.error)
        
        mockAuthService.shouldFail = false
        await authState.logout()
        
        XCTAssertNil(authState.error)
    }
    
    // MARK: - Session Restoration Tests
    
    func testRestoreSessionSetsUserFromStorage() async {
        let storedUser = User(id: "stored-1", email: "stored@test.com")
        try? await mockStorage.saveUser(storedUser)
        mockAuthService.mockUser = storedUser
        
        await authState.restoreSession()
        
        XCTAssertEqual(authState.user?.id, "stored-1")
    }
    
    func testRestoreSessionClearsStateOnInvalidSession() async {
        let storedUser = User(id: "1", email: "test@test.com")
        try? await mockStorage.saveUser(storedUser)
        mockAuthService.shouldFail = true
        mockAuthService.errorToThrow = .sessionExpired
        
        await authState.restoreSession()
        
        XCTAssertNil(authState.user)
        XCTAssertFalse(authState.isLoggedIn)
    }
    
    // MARK: - Session Invalidation Tests
    
    func testHandleSessionInvalidationClearsAllState() async {
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        mockRiderService.mockRider = Rider(id: "r1", userId: "1", type: .rider, createdAt: Date(), updatedAt: Date())
        await authState.login(email: "test@test.com", password: "password")
        
        XCTAssertTrue(authState.isLoggedIn)
        
        await authState.handleSessionInvalidation()
        
        XCTAssertFalse(authState.isLoggedIn)
        XCTAssertNil(authState.user)
        XCTAssertNil(authState.rider)
        XCTAssertNil(authState.error)
    }
    
    // MARK: - Error Handling Tests
    
    func testClearErrorRemovesError() async {
        mockAuthService.shouldFail = true
        mockAuthService.errorToThrow = .invalidCredentials
        await authState.login(email: "test@test.com", password: "wrong")
        
        XCTAssertNotNil(authState.error)
        
        authState.clearError()
        
        XCTAssertNil(authState.error)
    }
    
    // MARK: - Rider Profile Tests
    
    func testFetchRiderProfileSetsRider() async {
        let rider = Rider(id: "r1", userId: "1", type: .snowboarder, createdAt: Date(), updatedAt: Date())
        mockRiderService.mockRider = rider
        
        await authState.fetchRiderProfile()
        
        XCTAssertEqual(authState.rider?.id, "r1")
        XCTAssertEqual(authState.rider?.type, .snowboarder)
    }
    
    func testFetchRiderProfileSetsNilOnFailure() async {
        mockRiderService.shouldFail = true
        
        await authState.fetchRiderProfile()
        
        XCTAssertNil(authState.rider)
    }
    
    // MARK: - Token Access Tests
    
    func testGetAccessTokenReturnsTokenWhenExists() async {
        mockAuthService.mockAccessToken = "test-access-token"
        
        let token = await authState.getAccessToken()
        
        XCTAssertEqual(token, "test-access-token")
    }
    
    func testGetAccessTokenReturnsNilWhenNoToken() async {
        mockAuthService.mockAccessToken = nil
        
        let token = await authState.getAccessToken()
        
        XCTAssertNil(token)
    }
    
    // MARK: - Loading State Tests
    
    func testIsLoadingDuringLogin() async {
        XCTAssertFalse(authState.isLoading)
        
        // After completion, isLoading should be false
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        await authState.login(email: "test@test.com", password: "password")
        
        XCTAssertFalse(authState.isLoading)
    }
}

// MARK: - Mock Auth Service

actor MockAuthService: AuthServiceProtocol {
    var mockUser: User?
    var mockAccessToken: String?
    var shouldFail = false
    var errorToThrow: AuthError = .unknown("Mock error")
    
    func login(email: String, password: String) async throws -> AuthResponse {
        if shouldFail {
            throw errorToThrow
        }
        guard let user = mockUser else {
            throw AuthError.invalidCredentials
        }
        return AuthResponse(
            accessToken: "mock-access",
            refreshToken: "mock-refresh",
            user: user
        )
    }
    
    func register(email: String, password: String, name: String) async throws -> AuthResponse {
        if shouldFail {
            throw errorToThrow
        }
        guard let user = mockUser else {
            throw AuthError.serverError(statusCode: 422)
        }
        return AuthResponse(
            accessToken: "mock-access",
            refreshToken: "mock-refresh",
            user: user
        )
    }
    
    func logout() async throws {
        // No-op for mock
    }
    
    func fetchCurrentUser() async throws -> User {
        if shouldFail {
            throw errorToThrow
        }
        guard let user = mockUser else {
            throw AuthError.unauthorized
        }
        return user
    }
    
    func refreshSession() async throws -> AuthResponse {
        if shouldFail {
            throw errorToThrow
        }
        guard let user = mockUser else {
            throw AuthError.refreshFailed
        }
        return AuthResponse(
            accessToken: "new-access",
            refreshToken: "new-refresh",
            user: user
        )
    }
    
    func isAuthenticated() async -> Bool {
        mockUser != nil
    }
    
    func getAccessToken() async -> String? {
        mockAccessToken
    }
}

// MARK: - Mock Rider Service

actor MockRiderService: RiderServiceProtocol {
    var mockRider: Rider?
    var mockBaseLocation: RiderBaseLocation?
    var mockSports: [Sport] = []
    var mockRiderSports: [RiderSport] = []
    var shouldFail = false
    
    func fetchMyRider() async throws -> Rider {
        if shouldFail {
            throw AuthError.serverError(statusCode: 404)
        }
        guard let rider = mockRider else {
            throw AuthError.serverError(statusCode: 404)
        }
        return rider
    }
    
    func updateMyRider(_ update: UpdateRiderRequest) async throws -> Rider {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
        guard var rider = mockRider else {
            throw AuthError.serverError(statusCode: 404)
        }
        rider = Rider(
            id: rider.id,
            userId: rider.userId,
            type: update.type ?? rider.type ?? .rider,
            displayName: update.displayName ?? rider.displayName,
            description: update.description ?? rider.description,
            avatarUrl: rider.avatarUrl,
            createdAt: rider.createdAt,
            updatedAt: Date()
        )
        mockRider = rider
        return rider
    }
    
    func uploadAvatar(_ imageData: Data) async throws -> AvatarUploadResponse {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
        return AvatarUploadResponse(avatarUrl: "https://example.com/avatar.jpg")
    }
    
    func deleteMyAccount() async throws {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
    }
    
    func fetchMyBaseLocation() async throws -> RiderBaseLocation? {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
        return mockBaseLocation
    }
    
    func updateMyBaseLocation(_ location: UpdateBaseLocationRequest) async throws -> RiderBaseLocation {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
        let updated = RiderBaseLocation(latitude: location.latitude, longitude: location.longitude, name: location.name)
        mockBaseLocation = updated
        return updated
    }
    
    func fetchAllSports() async throws -> [Sport] {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
        return mockSports
    }
    
    func fetchMyRiderSports() async throws -> [RiderSport] {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
        return mockRiderSports
    }
    
    func upsertMyRiderSport(sportId: String, request: UpsertRiderSportRequest) async throws -> RiderSport {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
        let sport = RiderSport(id: UUID().uuidString, sportId: sportId, level: request.level, isMentor: request.isMentor)
        if let index = mockRiderSports.firstIndex(where: { $0.sportId == sportId }) {
            mockRiderSports[index] = sport
        } else {
            mockRiderSports.append(sport)
        }
        return sport
    }
    
    func deleteMyRiderSport(sportId: String) async throws {
        if shouldFail {
            throw AuthError.serverError(statusCode: 500)
        }
        mockRiderSports.removeAll { $0.sportId == sportId }
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
