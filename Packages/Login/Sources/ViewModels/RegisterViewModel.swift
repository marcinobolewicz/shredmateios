import Foundation
import Core
import Networking

/// ViewModel for RegisterView
@MainActor
@Observable
public final class RegisterViewModel {
    
    // MARK: - State
    
    public var name = ""
    public var email = ""
    public var password = ""
    public var confirmPassword = ""
    public var termsAccepted = false
    public var isLoading = false
    public var errorMessage: String?

    public var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.isValidEmail() &&
        !password.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword &&
        termsAccepted
    }
    
    public var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    /// Consent text with links to the current published document versions
    /// (falls back to canonical URLs until documents are loaded).
    public var consentMarkdown: String {
        let documents = authState.legalDocuments
        let privacyURL = documents.first { $0.type == .privacy }?.url ?? Self.fallbackPrivacyURL
        let termsURL = documents.first { $0.type == .terms }?.url ?? Self.fallbackTermsURL
        return RegisterStrings.consentMarkdown(privacyURL: privacyURL, termsURL: termsURL)
    }

    private static let fallbackPrivacyURL = "https://shredmate.pl/privacy"
    private static let fallbackTermsURL = "https://shredmate.pl/terms"

    // MARK: - Dependencies

    private let authState: AuthState
    private weak var router: AuthRouter?

    // MARK: - Init

    public init(authState: AuthState, router: AuthRouter) {
        self.authState = authState
        self.router = router
    }

    // MARK: - Actions

    /// Load current legal document versions so the consent links point at the
    /// exact versions that will be accepted on register.
    public func loadLegalDocuments() async {
        await authState.loadLegalDocumentsIfNeeded()
    }

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
        router?.reset()
    }
    
    public func clearError() {
        errorMessage = nil
        authState.clearError()
    }
}
