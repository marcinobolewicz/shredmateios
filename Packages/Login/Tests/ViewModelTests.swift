import XCTest
@testable import Login
@testable import Auth
@testable import Core

@MainActor
final class LoginViewModelTests: XCTestCase {
    
    private var viewModel: LoginViewModel!
    private var mockAuthState: AuthState!
    private var mockRouter: AuthRouter!
    private var mockStorage: MockTokenStorage!
    
    override func setUp() async throws {
        mockStorage = MockTokenStorage()
        let httpClient = AuthHTTPClient(baseURL: "https://test.com", tokenStorage: mockStorage)
        let authService = AuthService(httpClient: httpClient, tokenStorage: mockStorage)
        let riderService = RiderService(httpClient: httpClient)
        
        mockAuthState = AuthState(
            authService: authService,
            riderService: riderService,
            tokenStorage: mockStorage
        )
        mockRouter = AuthRouter()
        viewModel = LoginViewModel(authState: mockAuthState, router: mockRouter)
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testIsFormValidWithEmptyFields() {
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testIsFormValidWithValidEmail() {
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    func testIsFormValidWithInvalidEmail() {
        viewModel.email = "invalid-email"
        viewModel.password = "password"
        
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testNavigateToRegister() {
        viewModel.navigateToRegister()
        
        XCTAssertEqual(mockRouter.path.count, 1)
        XCTAssertEqual(mockRouter.path.first, .register)
    }
    
    func testNavigateToForgotPassword() {
        viewModel.navigateToForgotPassword()
        
        XCTAssertEqual(mockRouter.path.count, 1)
        XCTAssertEqual(mockRouter.path.first, .forgotPassword)
    }
}

@MainActor
final class RegisterViewModelTests: XCTestCase {
    
    private var viewModel: RegisterViewModel!
    private var mockRouter: AuthRouter!
    
    override func setUp() async throws {
        let mockStorage = MockTokenStorage()
        let httpClient = AuthHTTPClient(baseURL: "https://test.com", tokenStorage: mockStorage)
        let authService = AuthService(httpClient: httpClient, tokenStorage: mockStorage)
        let riderService = RiderService(httpClient: httpClient)
        
        let authState = AuthState(
            authService: authService,
            riderService: riderService,
            tokenStorage: mockStorage
        )
        mockRouter = AuthRouter()
        viewModel = RegisterViewModel(authState: authState, router: mockRouter)
    }
    
    func testIsFormValidWithEmptyFields() {
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testIsFormValidWithValidData() {
        viewModel.name = "John Doe"
        viewModel.email = "john@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    func testIsFormValidWithShortPassword() {
        viewModel.name = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "short"
        viewModel.confirmPassword = "short"
        
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testPasswordMismatch() {
        viewModel.password = "password123"
        viewModel.confirmPassword = "different"
        
        XCTAssertTrue(viewModel.passwordMismatch)
    }
    
    func testNavigateBack() {
        mockRouter.navigate(to: .register)
        
        viewModel.navigateBack()
        
        XCTAssertTrue(mockRouter.path.isEmpty)
    }
}

@MainActor
final class ForgotPasswordViewModelTests: XCTestCase {
    
    private var viewModel: ForgotPasswordViewModel!
    private var mockRouter: AuthRouter!
    
    override func setUp() async throws {
        mockRouter = AuthRouter()
        viewModel = ForgotPasswordViewModel(router: mockRouter, resetService: nil)
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isSuccess)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testIsFormValidWithEmptyEmail() {
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testIsFormValidWithValidEmail() {
        viewModel.email = "test@example.com"
        
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    func testIsFormValidWithInvalidEmail() {
        viewModel.email = "invalid"
        
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testNavigateBack() {
        mockRouter.navigate(to: .forgotPassword)
        
        viewModel.navigateBack()
        
        XCTAssertTrue(mockRouter.path.isEmpty)
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
