import SwiftUI
import Core
import Auth

/// Login view with navigation to Register and ForgotPassword
public struct LoginView: View {
    
    @State private var viewModel: LoginViewModel
    
    public init(viewModel: LoginViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                formSection
                actionsSection
                navigationLinks
            }
            .padding()
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
        VStack(spacing: 8) {
            Image("shredmate-logo", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(20)
                .background(
                    Circle()
                        .fill(.black)
                )
            
            Text("ShredMate")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await viewModel.login() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
    }
    
    private var navigationLinks: some View {
        VStack(spacing: 16) {
            Button("Forgot Password?") {
                viewModel.navigateToForgotPassword()
            }
            .font(.footnote)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundStyle(.secondary)
                Button("Sign Up") {
                    viewModel.navigateToRegister()
                }
                .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
        .padding(.top, 8)
    }
}

