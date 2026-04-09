import SwiftUI
import Core
import Theme
import Common

/// Forgot password view for password reset.
///
/// Visually consistent with login and register: a single frosted glass card
/// floating over the shared auth background owned by `AuthFlowView`.
public struct ForgotPasswordView: View {

    @Environment(AppTheme.self) private var theme
    @State private var viewModel: ForgotPasswordViewModel

    public init(viewModel: ForgotPasswordViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        AuthScreenLayout {
            VStack(spacing: theme.spacing.md) {
                AuthCardHeader(
                    title: ForgotPasswordStrings.headerTitle.localized,
                    subtitle: ForgotPasswordStrings.headerSubtitle.localized
                )

                if viewModel.isSuccess {
                    successSection
                        .padding(.top, theme.spacing.xs)
                } else {
                    formSection
                        .padding(.top, theme.spacing.xs)
                    resetButton
                        .padding(.top, theme.spacing.xs)
                }

                loginLink
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
        DSTextField(ForgotPasswordStrings.emailPlaceholder.localized, text: $viewModel.email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }

    private var resetButton: some View {
        DSLoadingButton(
            ForgotPasswordStrings.sendResetLinkButton.localized,
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.requestReset() }
        }
    }

    private var successSection: some View {
        VStack(spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: Self.successIconSize))
                .foregroundStyle(theme.colors.success, theme.colors.primaryForeground)
                .symbolRenderingMode(.palette)

            Text(ForgotPasswordStrings.successTitle.localized)
                .font(.headline)
                .foregroundStyle(theme.colors.primaryForeground)

            Text(ForgotPasswordStrings.successMessage(email: viewModel.email))
                .font(.subheadline)
                .foregroundStyle(theme.colors.primaryForeground.opacity(Self.subtitleOpacity))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var loginLink: some View {
        Button(ForgotPasswordStrings.backToSignInButton.localized) {
            viewModel.navigateBack()
        }
        .buttonStyle(.dsGhost)
    }

    // MARK: - Tuning

    private static let successIconSize: CGFloat = 48
    private static let subtitleOpacity: Double = 0.85
}
