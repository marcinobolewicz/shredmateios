import SwiftUI
import Core
import Auth
import Theme

/// Login view with navigation to Register and ForgotPassword
public struct LoginView: View {

    @Environment(AppTheme.self) private var theme
    @State private var viewModel: LoginViewModel

    public init(viewModel: LoginViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                headerSection
                formSection
                actionsSection
                navigationLinks
            }
            .padding(theme.spacing.md)
        }
        .navigationTitle(LoginStrings.navigationTitle.localized)
        .navigationBarTitleDisplayMode(.large)
        .alert(LoginStrings.errorTitle.localized, isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button(LoginStrings.ok.localized) { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: theme.spacing.xs) {
            Image("shredmate-logo", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(theme.spacing.lg)
                .background(
                    Circle()
                        .fill(.black)
                )

            Text(LoginStrings.appName.localized)
                .dsTextStyle(.largeTitle)

            Text(LoginStrings.subtitle.localized)
                .dsTextStyle(.subheadline)
        }
        .padding(.vertical, theme.spacing.lg)
    }

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
        VStack(spacing: theme.spacing.md) {
            Button(LoginStrings.forgotPasswordButton.localized) {
                viewModel.navigateToForgotPassword()
            }
            .buttonStyle(.dsGhost)

            HStack(spacing: theme.spacing.xxs) {
                Text(LoginStrings.noAccountPrompt.localized)
                    .dsTextStyle(.subheadline)

                Button(LoginStrings.signUpButton.localized) {
                    viewModel.navigateToRegister()
                }
                .buttonStyle(.dsGhost)
            }
        }
        .padding(.top, theme.spacing.xs)
    }
}

