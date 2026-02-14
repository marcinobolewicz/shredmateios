import SwiftUI
import App
import Theme

@main
struct ShredMateApp: App {
    @State private var dependencies = AppSetup.configure()
    @State private var theme = AppTheme.default

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
                .environment(dependencies.authState)
                .environment(theme)
        }
    }
}
