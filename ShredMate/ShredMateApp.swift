import SwiftUI
import App

@main
struct ShredMateApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isSetupComplete {
                RootView()
            } else {
                ProgressView()
                    .task {
                        await appState.setup()
                    }
            }
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isSetupComplete = false
    
    func setup() async {
        guard !isSetupComplete else { return }
        await AppSetup.configure()
        isSetupComplete = true
    }
}
