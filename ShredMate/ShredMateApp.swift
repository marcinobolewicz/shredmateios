import SwiftUI
import App

@main
struct ShredMateApp: App {
    @State private var isSetupComplete = false
    
    init() {
        // Perform synchronous initialization here if needed
    }
    
    var body: some Scene {
        WindowGroup {
            if isSetupComplete {
                RootView()
            } else {
                ProgressView()
                    .task {
                        await AppSetup.configure()
                        isSetupComplete = true
                    }
            }
        }
    }
}
