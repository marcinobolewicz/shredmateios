import SwiftUI
import Core
import Theme
import Common

/// Login view with navigation to Register and ForgotPassword.
///
/// Visually consistent with the welcome screen: a single frosted glass card
/// floating over the shared auth photo background. The background, scrim and
/// close button are owned by `AuthFlowView` so they persist across pushes.
public struct LoginView: View {

    @Environment(AppTheme.self) private var theme
    @State private var viewModel: LoginViewModel

    public init(viewModel: LoginViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        AuthScreenLayout {
            VStack(spacing: theme.spacing.md) {
                AuthCardHeader(
                    title: LoginStrings.navigationTitle.localized,
                    subtitle: LoginStrings.subtitle.localized
                )
                formSection
                    .padding(.top, theme.spacing.xs)
                actionsSection
                    .padding(.top, theme.spacing.xs)
                navigationLinks
            }
        }
        .alert(CommonStrings.errorTitle.localized, isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button(CommonStrings.okButton.localized) { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Sections

    private var formSection: some View {
        VStack(spacing: theme.spacing.md) {
            DSTextField(LoginStrings.emailPlaceholder.localized, text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            DSSecureField(LoginStrings.passwordPlaceholder.localized, text: $viewModel.password)
                .textContentType(.password)
        }
    }

    private var actionsSection: some View {
        DSLoadingButton(
            LoginStrings.signInButton.localized,
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.login() }
        }
    }

    private var navigationLinks: some View {
        VStack(spacing: theme.spacing.sm) {
            Button(LoginStrings.forgotPasswordButton.localized) {
                viewModel.navigateToForgotPassword()
            }
            .buttonStyle(.dsGhost)

            HStack(spacing: theme.spacing.xxs) {
                Text(LoginStrings.noAccountPrompt.localized)
                    .dsTextStyle(.subheadline, color: \.primaryForeground)

                Button(LoginStrings.signUpButton.localized) {
                    viewModel.navigateToRegister()
                }
                .buttonStyle(.dsGhost)
            }
        }
    }
}
