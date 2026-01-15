import SwiftUI
import Core
import Auth

/// Coordinator view for auth flow with NavigationStack
public struct AuthFlowView: View {
    
    @State private var router: AuthRouter
    private let authState: AuthState
    
    public init(authState: AuthState, router: AuthRouter = AuthRouter()) {
        self.authState = authState
        self._router = State(initialValue: router)
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(viewModel: makeLoginViewModel())
                .navigationDestination(for: AuthRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    // MARK: - Factory Methods
    
    @ViewBuilder
    private func destinationView(for route: AuthRoute) -> some View {
        switch route {
        case .login:
            LoginView(viewModel: makeLoginViewModel())
        case .register:
            RegisterView(viewModel: makeRegisterViewModel())
        case .forgotPassword:
            ForgotPasswordView(viewModel: makeForgotPasswordViewModel())
        }
    }
    
    private func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authState: authState, router: router)
    }
    
    private func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(authState: authState, router: router)
    }
    
    private func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(router: router, resetService: StubPasswordResetService())
    }
}
