import SwiftUI
import App

@main
struct ShredMateApp: App {
    @State private var authState: AuthState?
    
    var body: some Scene {
        WindowGroup {
            if let authState {
                RootView(authState: authState)
            } else {
                ProgressView("Ładowanie...")
                    .onAppear {
                        authState = AppSetup.configure()
                    }
            }
        }
    }
}
