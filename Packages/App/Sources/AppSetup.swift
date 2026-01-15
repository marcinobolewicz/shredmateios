import SwiftUI
import Core
import Networking
@_exported import Auth

/// App dependencies container
public struct AppDependencies: Sendable {
    public let authState: AuthState
    public let riderService: any RiderServiceProtocol
    
    public init(authState: AuthState, riderService: any RiderServiceProtocol) {
        self.authState = authState
        self.riderService = riderService
    }
}

/// App setup and DI configuration
@MainActor
public struct AppSetup {
    
    /// Configure app dependencies and return all dependencies for root view
    public static func configure() -> AppDependencies {
        let baseURL = "https://api.shredmate.eu/api/v1"
        
        // Create token storage
        let tokenStorage = TokenStorage()
        
        // Create HTTP client with token interceptor
        let httpClient = AuthHTTPClient(
            baseURL: baseURL,
            tokenStorage: tokenStorage
        )
        
        // Create services
        let authService = AuthService(httpClient: httpClient, tokenStorage: tokenStorage)
        let riderService = RiderService(httpClient: httpClient)
        
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
        container.register(AuthHTTPClient.self) { httpClient }
        container.register(RiderService.self) { riderService }
        
        return AppDependencies(authState: authState, riderService: riderService)
    }
}