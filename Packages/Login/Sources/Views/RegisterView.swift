import SwiftUI
import Core
import Auth
import Theme

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
                registerButton
                loginLink
            }
            .padding(theme.spacing.md)
        }
        .navigationTitle("Create Account")
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
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50))
                .foregroundStyle(theme.colors.primary)

            Text("Join ShredMate")
                .dsTextStyle(.title2)
        }
        .padding(.vertical, theme.spacing.md)
    }

    private var formSection: some View {
        VStack(spacing: theme.spacing.md) {
            DSTextField("Name", text: $viewModel.name)
                .textContentType(.name)
                .textInputAutocapitalization(.words)

            DSTextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            DSSecureField("Password", text: $viewModel.password)
                .textContentType(.newPassword)

            DSSecureField("Confirm Password", text: $viewModel.confirmPassword)
                .textContentType(.newPassword)

            if viewModel.passwordMismatch {
                DSErrorLabel("Passwords don't match")
            }

            DSHintLabel("Password must be at least 8 characters")
        }
    }

    private var registerButton: some View {
        DSLoadingButton(
            "Create Account",
            isLoading: viewModel.isLoading,
            isDisabled: !viewModel.isFormValid
        ) {
            Task { await viewModel.register() }
        }
    }

    private var loginLink: some View {
        HStack(spacing: theme.spacing.xxs) {
            Text("Already have an account?")
                .dsTextStyle(.subheadline)

            Button("Sign In") {
                viewModel.navigateBack()
            }
            .buttonStyle(.dsGhost)
        }
        .padding(.top, theme.spacing.xs)
    }
}
