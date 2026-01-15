import SwiftUI
import Core
import Networking

/// App setup and DI configuration
@MainActor
public struct AppSetup {
    public static func configure() async {
        // Get configuration
        let config = AppConfiguration.shared
        let baseURL = await config.getAPIBaseURL()
        
        // Setup DI container
        let container = DIContainer.shared
        
        // Register dependencies
        // Note: Actor initialization is synchronous, but their methods are async
        // For a more advanced setup, consider using async factories or pre-creating actors
        container.register(NetworkingService.self) {
            let client = URLSessionClient(baseURL: baseURL)
            return NetworkingService(client: client)
        }
    }
}
