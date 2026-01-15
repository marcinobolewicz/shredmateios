import SwiftUI
import Core

/// Forgot password view for password reset
public struct ForgotPasswordView: View {
    
    @State private var viewModel: ForgotPasswordViewModel
    
    public init(viewModel: ForgotPasswordViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                if viewModel.isSuccess {
                    successSection
                } else {
                    formSection
                    resetButton
                }
                
                loginLink
            }
            .padding()
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
        VStack(spacing: 8) {
            Image(systemName: "key.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            
            Text("Forgot your password?")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Enter your email and we'll send you a reset link")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
    }
    
    private var formSection: some View {
        TextField("Email", text: $viewModel.email)
            .textFieldStyle(.roundedBorder)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }
    
    private var resetButton: some View {
        Button {
            Task { await viewModel.requestReset() }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Send Reset Link")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }
    
    private var successSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("Check your inbox!")
                .font(.headline)
            
            Text("We've sent a password reset link to \(viewModel.email)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private var loginLink: some View {
        Button("Back to Sign In") {
            viewModel.navigateBack()
        }
        .font(.subheadline)
        .fontWeight(.semibold)
        .padding(.top, 8)
    }
}
