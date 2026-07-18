import Foundation
import Observation
import os.log

private let logger = Logger(subsystem: "com.shredmate.auth", category: "AuthState")

/// Authentication state for UI reactivity
@MainActor
@Observable
public final class AuthState {
    
    // MARK: - Published State

    public private(set) var user: User?
    public private(set) var rider: Rider?
    public private(set) var isLoading = false
    public private(set) var error: AuthError?
    public var sessionExpired = false
    public private(set) var isNewRegistration = false
    public private(set) var isLoggingOut = false

    /// Current versions of legal documents (loaded lazily for the register screen).
    public private(set) var legalDocuments: [LegalDocument] = []
    /// Current documents the logged-in user still has to accept (drives the blocking re-acceptance screen).
    public private(set) var pendingLegalDocuments: [LegalDocument] = []

    public var isLoggedIn: Bool { user != nil }

    // MARK: - Dependencies

    private let authService: any AuthServiceProtocol
    private let riderService: any RiderServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let pushDeviceService: (any PushDeviceServiceProtocol)?
    private let legalService: (any LegalServiceProtocol)?

    // MARK: - Init

    public init(
        authService: any AuthServiceProtocol,
        riderService: any RiderServiceProtocol,
        tokenStorage: TokenStorageProtocol,
        pushDeviceService: (any PushDeviceServiceProtocol)? = nil,
        legalService: (any LegalServiceProtocol)? = nil
    ) {
        self.authService = authService
        self.riderService = riderService
        self.tokenStorage = tokenStorage
        self.pushDeviceService = pushDeviceService
        self.legalService = legalService
    }
    
    // MARK: - Session Initialization
    
    private var hasRestoredSession = false
    
    /// Restore session on app launch (call from app init)
    public func restoreSession() async {
        // Only restore once per app launch
        guard !hasRestoredSession else { 
            logger.debug("Session already restored, skipping")
            return 
        }
        hasRestoredSession = true
        
        logger.debug("Starting session restore...")
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Check if we have tokens - this is the primary indicator of a session
        let hasTokens = await authService.isAuthenticated()
        logger.debug("Has stored tokens: \(hasTokens)")
        
        guard hasTokens else {
            logger.info("No tokens found, no session to restore")
            return
        }
        
        // Optionally load cached user for instant UI (before network validation)
        if let storedUser = await tokenStorage.loadUser() {
            logger.debug("Loaded cached user: \(storedUser.email)")
            user = storedUser
        } else {
            logger.debug("No cached user found")
        }
        
        // Validate session with backend and get fresh user data
        do {
            logger.debug("Validating session with backend...")
            let currentUser = try await authService.fetchCurrentUser()
            user = currentUser
            logger.info("Session restored for: \(currentUser.email)")
            
            // Persist fresh user data
            try? await tokenStorage.saveUser(currentUser)
            
            // Also fetch rider profile
            await fetchRiderProfile()
            await pushDeviceService?.registerCurrentTokenIfPossible()
            await refreshLegalStatus()
        } catch {
            logger.error("Session validation failed: \(error.localizedDescription)")
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
            await pushDeviceService?.registerCurrentTokenIfPossible()
            await refreshLegalStatus()
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

        // The backend requires acceptance of the current TERMS + PRIVACY versions
        // (once published). The consent checkbox in the register form covers them;
        // here we attach the exact versions being accepted.
        await loadLegalDocumentsIfNeeded()
        let acceptedDocuments = legalDocuments
            .filter { $0.type == .terms || $0.type == .privacy }
            .map(AcceptedDocument.init(document:))

        do {
            let response = try await authService.register(
                email: email,
                password: password,
                name: name,
                acceptedDocuments: acceptedDocuments
            )
            isNewRegistration = true
            user = response.user
            await fetchRiderProfile()
            await pushDeviceService?.registerCurrentTokenIfPossible()
        } catch let authError as AuthError {
            error = authError
        } catch {
            self.error = .unknown(error.localizedDescription)
        }

        isLoading = false
    }
    
    public func logout() async {
        isLoading = true
        isLoggingOut = true

        await pushDeviceService?.unregisterCurrentDeviceIfNeeded()

        try? await authService.logout()

        user = nil
        rider = nil
        error = nil
        sessionExpired = false
        pendingLegalDocuments = []
        isLoading = false
        isLoggingOut = false
    }
    
    // MARK: - Legal Documents & Consents

    /// Load current legal document versions (register screen links + acceptance payload).
    /// Failure is non-fatal: with an unreachable backend the register call itself
    /// will fail anyway, and the backend rejects registration without acceptances
    /// only once documents are published.
    public func loadLegalDocumentsIfNeeded() async {
        guard let legalService, legalDocuments.isEmpty else { return }
        do {
            legalDocuments = try await legalService.fetchDocuments()
        } catch {
            logger.warning("Failed to load legal documents: \(error.localizedDescription)")
        }
    }

    /// Refresh which documents the logged-in user still has to accept.
    /// Non-empty `pendingLegalDocuments` should block the app with a re-acceptance screen.
    public func refreshLegalStatus() async {
        guard let legalService, isLoggedIn else { return }
        do {
            let status = try await legalService.fetchStatus()
            legalDocuments = status.documents
            pendingLegalDocuments = status.requiresAcceptance
        } catch {
            // Non-fatal: don't lock the user out because a status check failed.
            logger.warning("Failed to refresh legal status: \(error.localizedDescription)")
        }
    }

    /// Accept all pending documents (re-acceptance flow). Returns true on success.
    @discardableResult
    public func acceptPendingLegalDocuments() async -> Bool {
        guard let legalService, !pendingLegalDocuments.isEmpty else { return true }
        do {
            let status = try await legalService.accept(
                documents: pendingLegalDocuments.map(AcceptedDocument.init(document:)),
                context: .reacceptance
            )
            legalDocuments = status.documents
            pendingLegalDocuments = status.requiresAcceptance
            return status.requiresAcceptance.isEmpty
        } catch {
            logger.error("Failed to accept legal documents: \(error.localizedDescription)")
            return false
        }
    }

    /// User declined the updated documents — end the session.
    public func declinePendingLegalDocuments() async {
        pendingLegalDocuments = []
        await logout()
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
        await pushDeviceService?.unregisterCurrentDeviceIfNeeded()
        try await riderService.deleteMyAccount()
        try? await tokenStorage.clearAll()
        user = nil
        rider = nil
        error = nil
    }
    
    // MARK: - Session Management

    public func handleSessionInvalidation() async {
        // Ignore invalidation triggered by our own logout flow — a concurrent 401
        // from an in-flight request would otherwise race with logout, surface as
        // sessionExpired and show the "session expired" alert right after the user
        // taps log out.
        guard !isLoggingOut else { return }
        let wasLoggedIn = isLoggedIn
        try? await tokenStorage.clearAll()
        user = nil
        rider = nil
        error = nil
        pendingLegalDocuments = []
        if wasLoggedIn {
            sessionExpired = true
        }
    }
    
    public func clearError() {
        error = nil
    }

    public func clearNewRegistration() {
        isNewRegistration = false
    }
    
    // MARK: - Token Access (for Socket.IO etc.)
    
    public func getAccessToken() async -> String? {
        await authService.getAccessToken()
    }
    
    public func tokensNeedRefresh() async -> Bool {
        guard let tokens = await authService.getTokens() else { return true }
        return tokens.isExpired
    }

    /// Proactively refreshes the session if the access token is expired.
    ///
    /// - Returns: `true` if the refresh succeeded (or was not needed), `false` on failure.
    @discardableResult
    public func refreshSessionIfNeeded() async -> Bool {
        guard await tokensNeedRefresh() else { return true }

        do {
            let response = try await authService.refreshSession()
            user = response.user
            logger.info("Session refreshed proactively")
            return true
        } catch {
            logger.error("Proactive session refresh failed: \(error.localizedDescription)")
            return false
        }
    }
}
