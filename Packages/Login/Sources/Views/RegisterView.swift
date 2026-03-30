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
                    .foregroundStyle(isAccepted ? theme.colors.primary : theme.colors.textTertiary)
            }
            .buttonStyle(.plain)

            Text(.init(RegisterStrings.consentMarkdown.localized))
                .font(.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .tint(theme.colors.textPrimary)
        }
    }
}

// MARK: - Register View

/// Register view for new user sign up
public struct RegisterView: View {

    @Environment(AppTheme.self) private var theme
    @State private var viewModel: RegisterViewModel

    public init(viewModel: RegisterViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                headerSection
                formSection
                LegalConsentRow(isAccepted: $viewModel.termsAccepted)
                registerButton
                loginLink
            }
            .padding(theme.spacing.md)
        }
        .navigationTitle(RegisterStrings.navigationTitle.localized)
        .navigationBarTitleDisplayMode(.large)
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

    private var headerSection: some View {
        VStack(spacing: theme.spacing.xs) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50))
                .foregroundStyle(theme.colors.primary)

            Text(RegisterStrings.headerTitle.localized)
                .dsTextStyle(.title2)
        }
        .padding(.vertical, theme.spacing.md)
    }

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

            DSHintLabel(RegisterStrings.passwordHint.localized)
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
                .dsTextStyle(.subheadline)

            Button(RegisterStrings.signInButton.localized) {
                viewModel.navigateBack()
            }
            .buttonStyle(.dsGhost)
        }
        .padding(.top, theme.spacing.xs)
    }
}
