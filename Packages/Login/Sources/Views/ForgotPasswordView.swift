import SwiftUI
import Core
import Theme

/// Forgot password view for password reset
public struct ForgotPasswordView: View {

    @Environment(AppTheme.self) private var theme
    @State private var viewModel: ForgotPasswordViewModel

    public init(viewModel: ForgotPasswordViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                headerSection

                if viewModel.isSuccess {
                    successSection
                } else {
                    formSection
                    resetButton
                }

                loginLink
            }
            .padding(theme.spacing.md)
        }
        .navigationTitle("Reset Password")
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
            Image(systemName: "key.fill")
                .font(.system(size: 50))
                .foregroundStyle(theme.colors.warning)

            Text("Forgot your password?")
                .dsTextStyle(.title2)

            Text("Enter your email and we'll send you a reset link")
                .dsTextStyle(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, theme.spacing.md)
    }

    private var formSection: some View {
        DSTextField("Email", text: $viewModel.email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }

    private var resetButton: some View {
        DSLoadingButton(
            "Send Reset Link",
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.requestReset() }
        }
    }

    private var successSection: some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(theme.colors.success)

            Text("Check your inbox!")
                .dsTextStyle(.heading)

            Text("We've sent a password reset link to \(viewModel.email)")
                .dsTextStyle(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, theme.spacing.lg)
    }

    private var loginLink: some View {
        Button("Back to Sign In") {
            viewModel.navigateBack()
        }
        .buttonStyle(.dsGhost)
        .padding(.top, theme.spacing.xs)
    }
}
