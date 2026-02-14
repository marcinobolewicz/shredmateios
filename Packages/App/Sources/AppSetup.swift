import SwiftUI
import Networking
import Core

@MainActor
@Observable
public final class AppDependencies {
    public let authState: AuthState
    public let riderService: any RiderServiceProtocol
    public let placesService: any PlacesServiceProtocol

    public init(
        authState: AuthState,
        riderService: any RiderServiceProtocol,
        placesService: any PlacesServiceProtocol
    ) {
        self.authState = authState
        self.riderService = riderService
        self.placesService = placesService
    }
}

/// App setup and DI configuration
@MainActor
public struct AppSetup {
    
    /// Configure app dependencies and return all dependencies for root view
    public static func configure() -> AppDependencies {
        let baseURL = URL(string: "https://api.shredmate.eu/api/v1")!
        
        let tokenStorage = TokenStorage()
        
        let tokenProvider = DefaultTokenProvider(
            tokenStorage: tokenStorage,
            baseURL: baseURL
        )
        
        // Create HTTP client with auto-auth (Bearer token, 401→refresh→retry)
        let httpClient = AuthenticatingHTTPClient(
            baseURL: baseURL,
            tokenProvider: tokenProvider
        )
        
        // Create services using new API-based approach
        let authService = AuthService(client: httpClient, tokenStorage: tokenStorage)
        let riderService = RiderService(client: httpClient)
        let placesService = PlacesService(client: httpClient)
        
        // Create auth state
        let authState = AuthState(
            authService: authService,
            riderService: riderService,
            tokenStorage: tokenStorage
        )
        
        // Configure session invalidation callback
        Task { @MainActor in
            await httpClient.setSessionInvalidationHandler {
                await authState.handleSessionInvalidation()
            }
        }
        
        // Register in DI container
        let container = DIContainer.shared
        container.register(AuthState.self) { authState }
        container.register(AuthenticatingHTTPClient.self) { httpClient }
        container.register(RiderServiceProtocol.self) { riderService }
        container.register(PlacesServiceProtocol.self) { placesService }
        
        return AppDependencies(authState: authState, riderService: riderService, placesService: placesService)
    }
}
