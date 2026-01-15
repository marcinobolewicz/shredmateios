import SwiftUI
import App

@main
struct ShredMateApp: App {
    init() {
        Task {
            await AppSetup.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
