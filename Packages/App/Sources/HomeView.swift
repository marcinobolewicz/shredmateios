import SwiftUI

/// Home view
public struct HomeView: View {
    @Binding var isAuthenticated: Bool
    
    public init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to ShredMate!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You are logged in")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button("Logout") {
                isAuthenticated = false
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
