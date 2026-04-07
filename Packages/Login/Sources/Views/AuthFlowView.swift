import SwiftUI
import Core
import Networking
import Theme

public enum AuthEntryPoint: Equatable {
    case login
    case register
    case forgotPassword

    fileprivate var route: AuthRoute {
        switch self {
        case .login:           .login
        case .register:        .register
        case .forgotPassword:  .forgotPassword
        }
    }
}

/// Container for the auth flow.
///
/// State-driven (no `NavigationStack`): a single `AuthRouter` exposes the
/// current route and a `switch` swaps the visible child. The close button
/// lives on the container and persists across all child states — there is
/// no system back button to compete with it. Each child view paints its
/// own background via `AuthScreenLayout`.
public struct AuthFlowView: View {

    @Environment(AuthState.self) private var authState
    @Environment(AppTheme.self) private var theme
    @State private var router: AuthRouter
    private let onClose: () -> Void
    private let onLoginSuccess: () -> Void

    public init(
        entry: AuthEntryPoint = .login,
        onClose: @escaping () -> Void,
        onLoginSuccess: @escaping () -> Void = {}
    ) {
        self.onClose = onClose
        self.onLoginSuccess = onLoginSuccess
        self._router = State(initialValue: AuthRouter(initial: entry.route))
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            currentScreen
                .transition(.opacity)
                .id(router.current)
            closeButton
        }
        .animation(.easeInOut(duration: Self.transitionDuration), value: router.current)
        .onChange(of: authState.isLoggedIn) { _, loggedIn in
            if loggedIn { onLoginSuccess() }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var currentScreen: some View {
        switch router.current {
        case .login:
            LoginView(viewModel: makeLoginViewModel())
        case .register:
            RegisterView(viewModel: makeRegisterViewModel())
        case .forgotPassword:
            ForgotPasswordView(viewModel: makeForgotPasswordViewModel())
        }
    }

    private var closeButton: some View {
        DSCloseButton(
            accessibilityLabel: AuthFlowStrings.closeAccessibilityLabel.localized,
            action: onClose
        )
        .padding(.leading, theme.spacing.md)
        .padding(.top, theme.spacing.md)
        .safeAreaPadding()
    }

    // MARK: - View model factories

    private func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(authState: authState, router: router)
    }

    private func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(authState: authState, router: router)
    }

    private func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(router: router, resetService: StubPasswordResetService())
    }

    // MARK: - Tuning

    private static let transitionDuration: Double = 0.25
}
