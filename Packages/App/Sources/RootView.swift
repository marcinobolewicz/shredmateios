import SwiftUI
import Login

/// Root view with simple routing between Login and Home
public struct RootView: View {
    @State private var isAuthenticated: Bool = false
    
    public init() {}
    
    public var body: some View {
        if isAuthenticated {
            HomeView(isAuthenticated: $isAuthenticated)
        } else {
            LoginView(isAuthenticated: $isAuthenticated)
        }
    }
}
