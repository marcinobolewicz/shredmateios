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
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") { viewModel.clearError() }
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

            Text("ShredMate")
                .dsTextStyle(.largeTitle)

            Text("Sign in to continue")
                .dsTextStyle(.subheadline)
        }
        .padding(.vertical, theme.spacing.lg)
    }

    private var formSection: some View {
        VStack(spacing: theme.spacing.md) {
            DSTextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            DSSecureField("Password", text: $viewModel.password)
                .textContentType(.password)
        }
    }

    private var actionsSection: some View {
        DSLoadingButton(
            "Sign In",
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.login() }
        }
    }

    private var navigationLinks: some View {
        VStack(spacing: theme.spacing.md) {
            Button("Forgot Password?") {
                viewModel.navigateToForgotPassword()
            }
            .buttonStyle(.dsGhost)

            HStack(spacing: theme.spacing.xxs) {
                Text("Don't have an account?")
                    .dsTextStyle(.subheadline)

                Button("Sign Up") {
                    viewModel.navigateToRegister()
                }
                .buttonStyle(.dsGhost)
            }
        }
        .padding(.top, theme.spacing.xs)
    }
}

