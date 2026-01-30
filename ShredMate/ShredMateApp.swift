import SwiftUI
import App

@main
struct ShredMateApp: App {
    @State private var dependencies = AppSetup.configure()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
                .environment(dependencies.authState)
        }
    }
}
