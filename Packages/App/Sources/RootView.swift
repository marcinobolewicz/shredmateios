import SwiftUI
import Auth
import Login

/// Root view that switches between auth flow and home based on session
public struct RootView: View {
    
    private let authState: AuthState
    private let riderService: any RiderServiceProtocol
    
    public init(authState: AuthState, riderService: any RiderServiceProtocol) {
        self.authState = authState
        self.riderService = riderService
    }
    
    public var body: some View {
        Group {
            if authState.isLoggedIn {
                HomeView(authState: authState, riderService: riderService)
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