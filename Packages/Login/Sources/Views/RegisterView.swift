import SwiftUI
import Core
import Theme
import Common

// MARK: - Legal Consent

private struct LegalConsentRow: View {
    @Environment(AppTheme.self) private var theme
    @Binding var isAccepted: Bool

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Button { isAccepted.toggle() } label: {
                Image(systemName: isAccepted ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(
                        isAccepted ? theme.colors.primary : theme.colors.primaryForeground.opacity(Self.unselectedOpacity)
                    )
            }
            .buttonStyle(.plain)

            Text(.init(RegisterStrings.consentMarkdown.localized))
                .font(.caption)
                .foregroundStyle(theme.colors.primaryForeground.opacity(Self.textOpacity))
                .tint(theme.colors.primaryForeground)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private static let unselectedOpacity: Double = 0.6
    private static let textOpacity: Double = 0.85
}

// MARK: - Register View

/// Register view for new user sign up.
///
/// Visually consistent with login and welcome: a single frosted glass card
/// floating over the shared auth background owned by `AuthFlowView`.
public struct RegisterView: View {

    @Environment(AppTheme.self) private var theme
    @State private var viewModel: RegisterViewModel

    public init(viewModel: RegisterViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        AuthScreenLayout {
            VStack(spacing: theme.spacing.md) {
                AuthCardHeader(title: RegisterStrings.headerTitle.localized)
                formSection
                    .padding(.top, theme.spacing.xs)
                LegalConsentRow(isAccepted: $viewModel.termsAccepted)
                registerButton
                    .padding(.top, theme.spacing.xs)
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
        VStack(spacing: theme.spacing.md) {
            DSTextField(RegisterStrings.namePlaceholder.localized, text: $viewModel.name)
                .textContentType(.name)
                .textInputAutocapitalization(.words)

            DSTextField(RegisterStrings.emailPlaceholder.localized, text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            DSSecureField(RegisterStrings.passwordPlaceholder.localized, text: $viewModel.password)
                .textContentType(.newPassword)

            DSSecureField(RegisterStrings.confirmPasswordPlaceholder.localized, text: $viewModel.confirmPassword)
                .textContentType(.newPassword)

            if viewModel.passwordMismatch {
                DSErrorLabel(RegisterStrings.passwordMismatch.localized)
            }

            DSHintLabel(
                RegisterStrings.passwordHint.localized,
                color: \.primaryForeground,
                opacity: Self.hintOpacity
            )
        }
    }

    private var registerButton: some View {
        DSLoadingButton(
            RegisterStrings.createAccountButton.localized,
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.register() }
        }
    }

    private var loginLink: some View {
        HStack(spacing: theme.spacing.xxs) {
            Text(RegisterStrings.alreadyHaveAccount.localized)
                .dsTextStyle(.subheadline, color: \.primaryForeground)

            Button(RegisterStrings.signInButton.localized) {
                viewModel.navigateBack()
            }
            .buttonStyle(.dsGhost)
        }
    }

    // MARK: - Tuning

    private static let hintOpacity: Double = 0.75
}
