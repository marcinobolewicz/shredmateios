import SwiftUI
import Networking
import Core
import Conversations

@MainActor
@Observable
public final class AppDependencies {
    public let authState: AuthState
    public let riderService: any RiderServiceProtocol
    public let placesService: any PlacesServiceProtocol
    public let chatService: any ChatServiceProtocol
    public let chatRealtimeClient: ChatRealtimeProviding
    public let chatRepository: ChatRepository
    public let chatLifecycleManager: ChatLifecycleManager
    public let chatEventHandler: ChatEventHandler

    public init(
        authState: AuthState,
        riderService: any RiderServiceProtocol,
        placesService: any PlacesServiceProtocol,
        chatService: any ChatServiceProtocol,
        chatRealtimeClient: ChatRealtimeProviding,
        chatRepository: ChatRepository,
        chatLifecycleManager: ChatLifecycleManager,
        chatEventHandler: ChatEventHandler
    ) {
        self.authState = authState
        self.riderService = riderService
        self.placesService = placesService
        self.chatService = chatService
        self.chatRealtimeClient = chatRealtimeClient
        self.chatRepository = chatRepository
        self.chatLifecycleManager = chatLifecycleManager
        self.chatEventHandler = chatEventHandler
    }
}

/// App setup and DI configuration
@MainActor
public struct AppSetup {
    
    /// Configure app dependencies and return all dependencies for root view
    public static func configure() -> AppDependencies {
        let (httpClient, authState) = configureAuth()
        let services = configureServices(httpClient: httpClient)
        let chat = configureChat(httpClient: httpClient, authState: authState)

        registerDependencies(
            authState: authState,
            httpClient: httpClient,
            services: services,
            chat: chat
        )

        return AppDependencies(
            authState: authState,
            riderService: services.rider,
            placesService: services.places,
            chatService: chat.service,
            chatRealtimeClient: chat.realtimeClient,
            chatRepository: chat.repository,
            chatLifecycleManager: chat.lifecycleManager,
            chatEventHandler: chat.eventHandler
        )
    }

    // MARK: - Auth

    private static func configureAuth() -> (AuthenticatingHTTPClient, AuthState) {
        let baseURL = URL(string: "https://api.shredmate.eu/api/v1")!
        let tokenStorage = TokenStorage()
        let tokenProvider = DefaultTokenProvider(tokenStorage: tokenStorage, baseURL: baseURL)

        let httpClient = AuthenticatingHTTPClient(
            baseURL: baseURL,
            tokenProvider: tokenProvider
        )

        let authService = AuthService(client: httpClient, tokenStorage: tokenStorage)
        let riderService = RiderService(client: httpClient)

        let authState = AuthState(
            authService: authService,
            riderService: riderService,
            tokenStorage: tokenStorage
        )

        Task { @MainActor in
            await httpClient.setSessionInvalidationHandler {
                await authState.handleSessionInvalidation()
            }
        }

        return (httpClient, authState)
    }

    // MARK: - Services

    private struct Services {
        let rider: any RiderServiceProtocol
        let places: any PlacesServiceProtocol
    }

    private static func configureServices(httpClient: AuthenticatingHTTPClient) -> Services {
        Services(
            rider: RiderService(client: httpClient),
            places: PlacesService(client: httpClient)
        )
    }

    // MARK: - Chat

    private struct ChatDependencies {
        let service: any ChatServiceProtocol
        let realtimeClient: ChatRealtimeProviding
        let repository: ChatRepository
        let lifecycleManager: ChatLifecycleManager
        let eventHandler: ChatEventHandler
    }

    private static func configureChat(
        httpClient: AuthenticatingHTTPClient,
        authState: AuthState
    ) -> ChatDependencies {
        let service = ChatService(client: httpClient)
        let realtimeClient = SocketIOChatClient()
        let repository = ChatRepository(chatService: service)
        let lifecycleManager = ChatLifecycleManager(
            realtimeClient: realtimeClient,
            authState: authState
        )
        let eventHandler = ChatEventHandler(
            realtimeClient: realtimeClient,
            repository: repository
        )

        return ChatDependencies(
            service: service,
            realtimeClient: realtimeClient,
            repository: repository,
            lifecycleManager: lifecycleManager,
            eventHandler: eventHandler
        )
    }

    // MARK: - DI Registration

    private static func registerDependencies(
        authState: AuthState,
        httpClient: AuthenticatingHTTPClient,
        services: Services,
        chat: ChatDependencies
    ) {
        let container = DIContainer.shared
        container.register(AuthState.self) { authState }
        container.register(AuthenticatingHTTPClient.self) { httpClient }
        container.register(RiderServiceProtocol.self) { services.rider }
        container.register(PlacesServiceProtocol.self) { services.places }
        container.register(ChatServiceProtocol.self) { chat.service }
        container.register(ChatRepository.self) { chat.repository }
        container.register(ChatLifecycleManager.self) { chat.lifecycleManager }
        container.register(ChatEventHandler.self) { chat.eventHandler }
    }
}
