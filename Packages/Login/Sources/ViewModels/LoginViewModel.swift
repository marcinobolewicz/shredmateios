import Foundation
import Core
import Auth

/// ViewModel for LoginView
@MainActor
@Observable
public final class LoginViewModel {
    
    // MARK: - State
    
    public var email = ""
    public var password = ""
    public var isLoading = false
    public var errorMessage: String?
    
    public var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    // MARK: - Dependencies
    
    private let authState: AuthState
    private weak var router: AuthRouter?
    
    // MARK: - Init
    
    public init(authState: AuthState, router: AuthRouter) {
        self.authState = authState
        self.router = router
    }
    
    // MARK: - Actions
    
    public func login() async {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        await authState.login(email: email, password: password)
        
        if let error = authState.error {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func navigateToRegister() {
        router?.navigate(to: .register)
    }
    
    public func navigateToForgotPassword() {
        router?.navigate(to: .forgotPassword)
    }
    
    public func clearError() {
        errorMessage = nil
        authState.clearError()
    }
}
