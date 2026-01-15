import Foundation
import Observation

/// Authentication state for UI reactivity
@MainActor
@Observable
public final class AuthState {
    
    // MARK: - Published State
    
    public private(set) var user: User?
    public private(set) var rider: Rider?
    public private(set) var isLoading = false
    public private(set) var error: AuthError?
    
    public var isLoggedIn: Bool { user != nil }
    
    // MARK: - Dependencies
    
    private let authService: AuthService
    private let riderService: RiderService
    private let tokenStorage: TokenStorageProtocol
    
    // MARK: - Init
    
    public init(
        authService: AuthService,
        riderService: RiderService,
        tokenStorage: TokenStorageProtocol
    ) {
        self.authService = authService
        self.riderService = riderService
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Session Initialization
    
    /// Restore session on app launch (call from app init)
    public func restoreSession() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Check for stored user first
        if let storedUser = await tokenStorage.loadUser() {
            user = storedUser
        }
        
        // Validate session with backend
        do {
            let currentUser = try await authService.fetchCurrentUser()
            user = currentUser
            
            // Also fetch rider profile
            await fetchRiderProfile()
        } catch {
            // Session invalid - clear state
            await handleSessionInvalidation()
        }
    }
    
    // MARK: - Auth Actions
    
    public func login(email: String, password: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await authService.login(email: email, password: password)
            user = response.user
            await fetchRiderProfile()
        } catch let authError as AuthError {
            error = authError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    public func register(email: String, password: String, name: String) async {
        isLoading = true
        error = nil
        
        do {
            let response = try await authService.register(
                email: email,
                password: password,
                name: name
            )
            user = response.user
            await fetchRiderProfile()
        } catch let authError as AuthError {
            error = authError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    public func logout() async {
        isLoading = true
        
        try? await authService.logout()
        
        user = nil
        rider = nil
        error = nil
        isLoading = false
    }
    
    // MARK: - Rider Actions
    
    public func fetchRiderProfile() async {
        do {
            rider = try await riderService.fetchMyRider()
        } catch {
            // Rider fetch failure is non-critical
            rider = nil
        }
    }
    
    public func updateRiderProfile(_ update: UpdateRiderRequest) async throws {
        rider = try await riderService.updateMyRider(update)
    }
    
    public func deleteAccount() async throws {
        try await riderService.deleteMyAccount()
        await handleSessionInvalidation()
    }
    
    // MARK: - Session Management
    
    public func handleSessionInvalidation() async {
        try? await tokenStorage.clearAll()
        user = nil
        rider = nil
        error = nil
    }
    
    public func clearError() {
        error = nil
    }
    
    // MARK: - Token Access (for Socket.IO etc.)
    
    public func getAccessToken() async -> String? {
        await authService.getAccessToken()
    }
    
    public func tokensNeedRefresh() async -> Bool {
        guard let tokens = await authService.getTokens() else { return true }
        return tokens.isExpired
    }
}
