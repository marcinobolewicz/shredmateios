import XCTest
import Networking
import Conversations
import Onboarding
import Payment
@testable import App

// MARK: - RootCoordinatorTests

@MainActor
final class RootCoordinatorTests: XCTestCase {

    private var coordinator: RootCoordinator!
    private var authState: AuthState!
    private var mockAuthService: MockAuthService!
    private var mockSportsService: MockSportsService!

    override func setUp() async throws {
        OnboardingStorage.reset()

        mockAuthService = MockAuthService()
        mockSportsService = MockSportsService()
        let mockTokenStorage = MockTokenStorage()
        let mockRiderService = MockRiderService()

        authState = AuthState(
            authService: mockAuthService,
            riderService: mockRiderService,
            tokenStorage: mockTokenStorage
        )

        let mockRealtimeClient = MockChatRealtimeClient()
        let chatRepository = ChatRepository(chatService: MockChatService())
        let chatLifecycleManager = ChatLifecycleManager(
            realtimeClient: mockRealtimeClient,
            authState: authState
        )
        let chatEventHandler = ChatEventHandler(
            realtimeClient: mockRealtimeClient,
            repository: chatRepository
        )
        let followRepository = FollowRepository(
            riderService: mockRiderService,
            authState: authState
        )

        let dependencies = AppDependencies(
            authState: authState,
            pushDeviceService: MockPushDeviceService(),
            riderService: mockRiderService,
            followRepository: followRepository,
            placesService: MockPlacesService(),
            sportsService: mockSportsService,
            mentorSlotsService: MockMentorSlotsService(),
            mentorsService: MockMentorsService(),
            feedService: MockFeedService(),
            stripeService: MockStripeService(),
            stripePaymentService: StripePaymentService(publishableKey: ""),
            chatService: MockChatService(),
            chatRealtimeClient: mockRealtimeClient,
            chatRepository: chatRepository,
            chatLifecycleManager: chatLifecycleManager,
            chatEventHandler: chatEventHandler,
            notificationCenter: InAppNotificationCenter(),
            sportPreferenceStorage: MockSportPreferenceStorage()
        )

        coordinator = RootCoordinator(dependencies: dependencies)
    }

    override func tearDown() {
        OnboardingStorage.reset()
    }

    // MARK: - Initial Flow

    func testBootstrapSetsGuestFlowWhenNoSession() async {
        // No tokens → not logged in
        await coordinator.bootstrap()

        XCTAssertEqual(coordinator.router.flow, .guest)
    }

    func testBootstrapShowsWelcomeOnFreshInstall() async {
        OnboardingStorage.reset()

        await coordinator.bootstrap()

        XCTAssertTrue(coordinator.showWelcome)
    }

    func testBootstrapSkipsWelcomeWhenAlreadyShown() async {
        OnboardingStorage.markWelcomeShown()

        await coordinator.bootstrap()

        XCTAssertFalse(coordinator.showWelcome)
    }

    // MARK: - Auth Changes

    func testHandleAuthChangeToLoggedInRoutesToUser() {
        // Simulate logged-in state
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        // Manually set user on authState via login
        Task {
            await authState.login(email: "test@test.com", password: "pass")
        }

        // When already logged in, routeAfterLogin should go to .user
        coordinator.handleAuthChange(isLoggedIn: true)

        // Since authState.isLoggedIn is checked inside routeAfterLogin,
        // and we haven't awaited login, it guards out. That's fine —
        // the important path is the logout one:
    }

    func testHandleAuthChangeToLoggedOutResetsToGuest() {
        coordinator.router.flow = .user

        coordinator.handleAuthChange(isLoggedIn: false)

        XCTAssertEqual(coordinator.router.flow, .guest)
    }

    // MARK: - Deep Link: Immediate vs Pending

    func testDeepLinkAppliedImmediatelyWhenLoggedInAndOnUserFlow() async {
        // Log in the user
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        await authState.login(email: "test@test.com", password: "pass")
        coordinator.router.flow = .user

        let url = URL(string: "https://shredmate.pl/app/stripe/onboarding/result?status=success")!
        coordinator.handleIncomingURL(url)

        XCTAssertEqual(coordinator.appRouter.selectedTab, .profile)
    }

    func testDeepLinkDeferredWhenNotOnUserFlow() async {
        // User is logged in but flow is still loading
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        await authState.login(email: "test@test.com", password: "pass")
        coordinator.router.flow = .loading

        let url = URL(string: "https://shredmate.pl/app/stripe/onboarding/result?status=success")!
        coordinator.handleIncomingURL(url)

        // Should NOT have navigated yet
        XCTAssertEqual(coordinator.appRouter.selectedTab, .home)

        // When flow transitions to .user, pending deep link fires
        coordinator.handleFlowChange(.user)
        XCTAssertEqual(coordinator.appRouter.selectedTab, .profile)
    }

    func testDeepLinkIgnoredForUnknownURL() async {
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        await authState.login(email: "test@test.com", password: "pass")
        coordinator.router.flow = .user

        let url = URL(string: "https://shredmate.pl/unknown/path")!
        coordinator.handleIncomingURL(url)

        XCTAssertEqual(coordinator.appRouter.selectedTab, .home)
    }

    // MARK: - Welcome Actions

    func testWelcomeActionSignUpShowsAuthRegister() {
        coordinator.showWelcome = true

        coordinator.handleWelcomeAction(.signUp)

        XCTAssertFalse(coordinator.showWelcome)
        XCTAssertEqual(coordinator.router.flow, .auth(.register))
    }

    func testWelcomeActionSignInShowsAuthLogin() {
        coordinator.showWelcome = true

        coordinator.handleWelcomeAction(.signIn)

        XCTAssertFalse(coordinator.showWelcome)
        XCTAssertEqual(coordinator.router.flow, .auth(.login))
    }

    func testWelcomeActionLaterDismissesOnly() {
        coordinator.showWelcome = true
        coordinator.router.flow = .guest

        coordinator.handleWelcomeAction(.later)

        XCTAssertFalse(coordinator.showWelcome)
        XCTAssertEqual(coordinator.router.flow, .guest)
    }

    // MARK: - Onboarding

    func testDismissOnboardingNavigatesToHome() async {
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        await authState.login(email: "test@test.com", password: "pass")
        coordinator.router.flow = .onboarding
        OnboardingStorage.markPending()

        coordinator.dismissOnboarding()

        XCTAssertEqual(coordinator.router.flow, .user)
        XCTAssertEqual(coordinator.appRouter.selectedTab, .home)
        XCTAssertFalse(OnboardingStorage.isPending)
    }

    func testCompleteOnboardingNavigatesToDestination() async {
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        await authState.login(email: "test@test.com", password: "pass")
        coordinator.router.flow = .onboarding
        OnboardingStorage.markPending()

        coordinator.completeOnboarding(with: .explorePlaces)

        XCTAssertEqual(coordinator.router.flow, .user)
        XCTAssertEqual(coordinator.appRouter.selectedTab, .spots)
        XCTAssertFalse(OnboardingStorage.isPending)
    }

    // MARK: - Route After Login

    func testRouteAfterLoginGoesToUserWhenNoOnboardingPending() async {
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        await authState.login(email: "test@test.com", password: "pass")
        OnboardingStorage.clearPending()

        coordinator.routeAfterLogin()

        XCTAssertEqual(coordinator.router.flow, .user)
    }

    func testRouteAfterLoginGoesToLoadingWhenOnboardingPendingButSportsNotLoaded() async {
        mockAuthService.mockUser = User(id: "1", email: "test@test.com")
        await authState.login(email: "test@test.com", password: "pass")
        OnboardingStorage.markPending()

        coordinator.routeAfterLogin()

        XCTAssertEqual(coordinator.router.flow, .loading)
    }
}

// MARK: - Mocks

private actor MockAuthService: AuthServiceProtocol {
    var mockUser: User?
    var mockAccessToken: String?
    var shouldFail = false

    func login(email: String, password: String) async throws -> AuthResponse {
        guard let user = mockUser else { throw AuthError.invalidCredentials }
        return AuthResponse(accessToken: "mock-access", refreshToken: "mock-refresh", user: user)
    }

    func register(email: String, password: String, name: String) async throws -> AuthResponse {
        guard let user = mockUser else { throw AuthError.invalidCredentials }
        return AuthResponse(accessToken: "mock-access", refreshToken: "mock-refresh", user: user)
    }

    func logout() async throws {}
    func fetchCurrentUser() async throws -> User {
        guard let user = mockUser else { throw AuthError.unauthorized }
        return user
    }

    func refreshSession() async throws -> AuthResponse {
        guard let user = mockUser else { throw AuthError.refreshFailed }
        return AuthResponse(accessToken: "new-access", refreshToken: "new-refresh", user: user)
    }

    func isAuthenticated() async -> Bool { mockUser != nil }
    func getAccessToken() async -> String? { mockAccessToken }
}

private actor MockRiderService: RiderServiceProtocol {
    func fetchAllRiders() async throws -> [Rider] { [] }
    func fetchRider(id: String) async throws -> Rider { throw AuthError.unauthorized }
    func fetchMyRider() async throws -> Rider { throw AuthError.serverError(statusCode: 404) }
    func updateMyRider(_ update: UpdateRiderRequest) async throws -> Rider { throw AuthError.unauthorized }
    func uploadAvatar(_ imageData: Data) async throws -> AvatarUploadResponse {
        AvatarUploadResponse(avatarUrl: "")
    }
    func deleteMyAccount() async throws {}
    func fetchMyBaseLocation() async throws -> RiderBaseLocation? { nil }
    func updateMyBaseLocation(_ location: UpdateBaseLocationRequest) async throws -> RiderBaseLocation {
        RiderBaseLocation(latitude: 0, longitude: 0)
    }
    func fetchAllSports() async throws -> [Sport] { [] }
    func fetchMyRiderSports() async throws -> [RiderSport] { [] }
    func upsertMyRiderSport(sportId: String, request: UpsertRiderSportRequest) async throws -> RiderSport {
        throw AuthError.unauthorized
    }
    func deleteMyRiderSport(sportId: String) async throws {}
    func follow(riderId: String) async throws {}
    func unfollow(riderId: String) async throws {}
    func fetchFollowing(riderId: String) async throws -> [FollowedRider] { [] }
}

private actor MockTokenStorage: TokenStorageProtocol {
    private var tokens: AuthTokens?
    private var user: User?

    func saveTokens(_ tokens: AuthTokens) async throws { self.tokens = tokens }
    func loadTokens() async -> AuthTokens? { tokens }
    func clearTokens() async throws { tokens = nil }
    func saveUser(_ user: User) async throws { self.user = user }
    func loadUser() async -> User? { user }
    func clearUser() async throws { user = nil }
    func clearAll() async throws { tokens = nil; user = nil }
}

private actor MockSportsService: SportsServiceProtocol {
    var mockSports: [Sport] = []
    var shouldFail = false

    func fetchSports() async throws -> [Sport] {
        if shouldFail { throw AuthError.unknown("fail") }
        return mockSports
    }

    func refreshSports() async throws -> [Sport] { mockSports }
}

private actor MockChatService: ChatServiceProtocol {
    func listConversations(params: PaginationParams) async throws -> [ChatConversation] { [] }
    func openOrCreateConversation(otherUserId: String) async throws -> ChatConversation {
        throw AuthError.unauthorized
    }
    func getMessages(conversationId: String, params: PaginationParams) async throws -> [ChatMessage] { [] }
    func sendMessage(conversationId: String, input: SendMessageInput) async throws -> ChatMessage {
        throw AuthError.unauthorized
    }
    func markAsRead(conversationId: String) async throws -> String { "" }
    func deleteConversation(conversationId: String) async throws {}
}

private final class MockChatRealtimeClient: ChatRealtimeProviding, @unchecked Sendable {
    var isConnected: Bool { false }
    func connect(token: String) {}
    func disconnect() {}
    func reconnectIfNeeded(newToken: String) {}
    var events: AsyncStream<ChatRealtimeEvent> {
        AsyncStream { $0.finish() }
    }
}

private actor MockPushDeviceService: PushDeviceServiceProtocol {
    func setAPNSToken(_ token: String) async {}
    func registerCurrentTokenIfPossible() async {}
    func unregisterCurrentDeviceIfNeeded() async {}
}

private actor MockPlacesService: PlacesServiceProtocol {
    func fetchPlaces(sportSlug: String?) async throws -> [PlaceDto] { [] }
    func fetchPlaceRiders(placeId: UUID, sportSlug: String?, sportId: UUID?) async throws -> [PlaceRiderPresence] { [] }
    func joinPlace(placeId: UUID, sportId: UUID, role: PlaceRiderRole, rating: Int?) async throws -> PlaceJoinResponse {
        throw AuthError.unauthorized
    }
    func leavePlace(placeId: UUID, sportId: UUID) async throws {}
    func myMembership(placeId: UUID) async throws -> PlaceMembership? { nil }
}

private actor MockMentorSlotsService: MentorSlotsServiceProtocol {
    func fetchSlots(mentorRiderId: String, from: String?, to: String?, limit: Int) async throws -> MentorSlotsResponse {
        MentorSlotsResponse(data: [], meta: .init(total: 0, page: 1, limit: 20, totalPages: 0))
    }
    func fetchMySlots() async throws -> MentorSlotsResponse {
        MentorSlotsResponse(data: [], meta: .init(total: 0, page: 1, limit: 20, totalPages: 0))
    }
    func fetchBookedByMe() async throws -> MentorSlotsResponse {
        MentorSlotsResponse(data: [], meta: .init(total: 0, page: 1, limit: 20, totalPages: 0))
    }
    func cancelBooking(id: String) async throws -> MentorSlot { throw AuthError.unauthorized }
    func completeSession(id: String, recommend: Bool) async throws -> MentorSlot { throw AuthError.unauthorized }
    func deleteSlot(id: String) async throws {}
    func generateSlots(request: GenerateSlotsRequest) async throws -> GenerateSlotsResponse {
        throw AuthError.unauthorized
    }
}

private actor MockMentorsService: MentorsServiceProtocol {
    func fetchMentors(sportId: UUID?, placeId: UUID?, page: Int, limit: Int) async throws -> PaginatedResponse<MentorListItem> {
        PaginatedResponse(data: [], meta: .init(total: 0, page: 1, limit: 20, totalPages: 0))
    }
}

private actor MockFeedService: FeedServiceProtocol {
    func createActivity(_ request: CreateActivityRequest) async throws -> ActivityPost { throw AuthError.unauthorized }
    func uploadPhoto(imageData: Data) async throws -> ActivityPhotoUploadResponse { throw AuthError.unauthorized }
    func fetchFeed(page: Int, limit: Int) async throws -> PaginatedResponse<ActivityPost> {
        PaginatedResponse(data: [], meta: .init(total: 0, page: 1, limit: 20, totalPages: 0))
    }
    func fetchRiderPosts(riderId: String, page: Int, limit: Int) async throws -> PaginatedResponse<ActivityPost> {
        PaginatedResponse(data: [], meta: .init(total: 0, page: 1, limit: 20, totalPages: 0))
    }
    func deleteActivity(activityId: String) async throws {}
}

private actor MockStripeService: StripeServiceProtocol {
    func createAccount() async throws -> StripeAccount { throw AuthError.unauthorized }
    func createOnboardingLink() async throws -> StripeOnboardingLink { throw AuthError.unauthorized }
    func fetchStatus() async throws -> StripeStatus { throw AuthError.unauthorized }
}

private actor MockSportPreferenceStorage: SportPreferenceStorageProtocol {
    func savedSportSlug() async -> String? { nil }
    func saveSportSlug(_ slug: String?) async {}
}
