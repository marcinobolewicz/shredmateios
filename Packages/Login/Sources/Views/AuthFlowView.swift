import SwiftUI
import Core
import Auth

public enum AuthEntryPoint: Equatable {
    case login
    case register
    case forgotPassword
}

public struct AuthFlowView: View {

    @State private var router: AuthRouter
    private let authState: AuthState
    private let entry: AuthEntryPoint
    private let onClose: () -> Void
    private let onLoginSuccess: () -> Void

    public init(
        authState: AuthState,
        entry: AuthEntryPoint = .login,
        router: AuthRouter = AuthRouter(),
        onClose: @escaping () -> Void,
        onLoginSuccess: @escaping () -> Void = {}
    ) {
        self.authState = authState
        self.entry = entry
        self.onClose = onClose
        self.onLoginSuccess = onLoginSuccess
        self._router = State(initialValue: router)
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            startView()
                .navigationDestination(for: AuthRoute.self) { route in
                    destinationView(for: route)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel("Zamknij logowanie")
                    }
                }
        }
        .onChange(of: authState.isLoggedIn) { _, loggedIn in
            if loggedIn { onLoginSuccess() }
        }
    }

    @ViewBuilder
    private func startView() -> some View {
        switch entry {
        case .login:
            LoginView(viewModel: makeLoginViewModel())
        case .register:
            RegisterView(viewModel: makeRegisterViewModel())
        case .forgotPassword:
            ForgotPasswordView(viewModel: makeForgotPasswordViewModel())
        }
    }

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
