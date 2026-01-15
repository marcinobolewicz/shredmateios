import Foundation
import Core
import Auth

/// ViewModel for RegisterView
@MainActor
@Observable
public final class RegisterViewModel {
    
    // MARK: - State
    
    public var name = ""
    public var email = ""
    public var password = ""
    public var confirmPassword = ""
    public var isLoading = false
    public var errorMessage: String?
    
    public var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }
    
    public var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
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
    
    public func register() async {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        await authState.register(email: email, password: password, name: name)
        
        if let error = authState.error {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public func navigateBack() {
        router?.pop()
    }
    
    public func clearError() {
        errorMessage = nil
        authState.clearError()
    }
}
