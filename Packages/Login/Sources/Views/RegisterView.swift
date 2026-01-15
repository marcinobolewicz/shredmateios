import SwiftUI
import Core
import Auth

/// Register view for new user sign up
public struct RegisterView: View {
    
    @State private var viewModel: RegisterViewModel
    
    public init(viewModel: RegisterViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                formSection
                registerButton
                loginLink
            }
            .padding()
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
        VStack(spacing: 8) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            
            Text("Join ShredMate")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 16)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .textInputAutocapitalization(.words)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)
            
            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                .textFieldStyle(.roundedBorder)
                .textContentType(.newPassword)
            
            if viewModel.passwordMismatch {
                Text("Passwords don't match")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            Text("Password must be at least 8 characters")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var registerButton: some View {
        Button {
            Task { await viewModel.register() }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }
    
    private var loginLink: some View {
        HStack {
            Text("Already have an account?")
                .foregroundStyle(.secondary)
            Button("Sign In") {
                viewModel.navigateBack()
            }
            .fontWeight(.semibold)
        }
        .font(.subheadline)
        .padding(.top, 8)
    }
}
