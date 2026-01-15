import SwiftUI
import Auth
import Login

/// Root view that switches between auth flow and home based on session
public struct RootView: View {
    
    private let authState: AuthState
    
    public init(authState: AuthState) {
        self.authState = authState
    }
    
    public var body: some View {
        Group {
            if authState.isLoggedIn {
                HomeView(authState: authState)
            } else {
                AuthFlowView(authState: authState)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authState.isLoggedIn)
        .task {
            await authState.restoreSession()
        }
    }
}

