import Foundation
import Core
import Auth

/// Protocol for password reset service (enables testing)
public protocol PasswordResetServicing: Sendable {
    func requestPasswordReset(email: String) async throws
}

/// ViewModel for ForgotPasswordView
@MainActor
@Observable
public final class ForgotPasswordViewModel {
    
    // MARK: - State
    
    public var email = ""
    public var isLoading = false
    public var errorMessage: String?
    public var isSuccess = false
    
    public var isFormValid: Bool {
        !email.isEmpty && email.isValidEmail()
    }
    
    // MARK: - Dependencies
    
    private let resetService: PasswordResetServicing?
    private weak var router: AuthRouter?
    
    // MARK: - Init
    
    public init(router: AuthRouter, resetService: PasswordResetServicing? = nil) {
        self.router = router
        self.resetService = resetService
    }
    
    // MARK: - Actions
    
    public func requestReset() async {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await resetService?.requestPasswordReset(email: email)
            isSuccess = true
        } catch {
//            TODO: localize
            errorMessage = "Failed to send reset email. Please try again."
        }
        
        isLoading = false
    }
    
    public func navigateBack() {
        router?.pop()
    }
    
    public func clearError() {
        errorMessage = nil
    }
}

/// Stub implementation for password reset (replace with real service)
public actor StubPasswordResetService: PasswordResetServicing {
    
    public init() {}
    
    public func requestPasswordReset(email: String) async throws {
        // Simulate network delay
        try await Task.sleep(for: .seconds(1))
        // Stub always succeeds
    }
}
