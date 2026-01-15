import SwiftUI

/// Login view
public struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    
    public init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("ShredMate")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button("Login") {
                // Simple stub authentication
                isAuthenticated = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(username.isEmpty || password.isEmpty)
        }
        .padding()
    }
}
