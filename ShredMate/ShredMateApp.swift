import SwiftUI
import App

@main
struct ShredMateApp: App {
    @State private var dependencies: AppDependencies?
    
    var body: some Scene {
        WindowGroup {
            if let dependencies {
                RootView(
                    authState: dependencies.authState,
                    riderService: dependencies.riderService
                )
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        dependencies = AppSetup.configure()
                    }
            }
        }
    }
}