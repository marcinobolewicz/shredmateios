import SwiftUI
import Networking
import Core
import Conversations
import Pulse

@MainActor
@Observable
public final class AppDependencies {
    public let authState: AuthState
    public let pushDeviceService: any PushDeviceServiceProtocol
    public let riderService: any RiderServiceProtocol
    public let followRepository: FollowRepository
    public let placesService: any PlacesServiceProtocol
    public let sportsService: any SportsServiceProtocol
    public let feedService: any FeedServiceProtocol
    public let chatService: any ChatServiceProtocol
    public let chatRealtimeClient: ChatRealtimeProviding
    public let chatRepository: ChatRepository
    public let chatLifecycleManager: ChatLifecycleManager
    public let chatEventHandler: ChatEventHandler
    public let notificationCenter: InAppNotificationCenter

    public init(
        authState: AuthState,
        pushDeviceService: any PushDeviceServiceProtocol,
        riderService: any RiderServiceProtocol,
        followRepository: FollowRepository,
        placesService: any PlacesServiceProtocol,
        sportsService: any SportsServiceProtocol,
        feedService: any FeedServiceProtocol,
        chatService: any ChatServiceProtocol,
        chatRealtimeClient: ChatRealtimeProviding,
        chatRepository: ChatRepository,
        chatLifecycleManager: ChatLifecycleManager,
        chatEventHandler: ChatEventHandler,
        notificationCenter: InAppNotificationCenter
    ) {
        self.authState = authState
        self.pushDeviceService = pushDeviceService
        self.riderService = riderService
        self.followRepository = followRepository
        self.placesService = placesService
        self.sportsService = sportsService
        self.feedService = feedService
        self.chatService = chatService
        self.chatRealtimeClient = chatRealtimeClient
        self.chatRepository = chatRepository
        self.chatLifecycleManager = chatLifecycleManager
        self.chatEventHandler = chatEventHandler
        self.notificationCenter = notificationCenter
    }
}

/// App setup and DI configuration
@MainActor
public struct AppSetup {
    
    /// Configure app dependencies and return all dependencies for root view
    public static func configure() -> AppDependencies {
        let auth = configureAuth()
        let services = configureServices(httpClient: auth.httpClient)
        let chat = configureChat(httpClient: auth.httpClient, authState: auth.authState)
        let notificationCenter = InAppNotificationCenter()
        
        // Wire socket → in-app banner
        chat.eventHandler.onMessageReceived = { [weak notificationCenter] senderName, text, conversationId in
            let notification = InAppNotification(
                title: senderName.isEmpty ? "Nowa wiadomość" : senderName,
                body: text,
                conversationId: conversationId
            )
            notificationCenter?.post(notification)
        }

        registerDependencies(
            authState: auth.authState,
            httpClient: auth.httpClient,
            pushDeviceService: auth.pushDeviceService,
            services: services,
            chat: chat
        )

        let followRepository = FollowRepository(
            riderService: services.rider,
            authState: auth.authState
        )

        return AppDependencies(
            authState: auth.authState,
            pushDeviceService: auth.pushDeviceService,
            riderService: services.rider,
            followRepository: followRepository,
            placesService: services.places,
            sportsService: services.sports,
            feedService: services.feed,
            chatService: chat.service,
            chatRealtimeClient: chat.realtimeClient,
            chatRepository: chat.repository,
            chatLifecycleManager: chat.lifecycleManager,
            chatEventHandler: chat.eventHandler,
            notificationCenter: notificationCenter
        )
    }

    // MARK: - Auth

    private struct AuthDependencies {
        let httpClient: AuthenticatingHTTPClient
        let authState: AuthState
        let pushDeviceService: any PushDeviceServiceProtocol
    }

    private static func configureAuth() -> AuthDependencies {
        let baseURL = URL(string: "https://api.shredmate.eu/api/v1")!
        let tokenStorage = TokenStorage()
        let pushDeviceStorage = PushDeviceStorage()
        let tokenProvider = DefaultTokenProvider(tokenStorage: tokenStorage, baseURL: baseURL)

        #if DEBUG
        let networkSession: any NetworkSessioning = URLSessionProxy(configuration: .default)
        #else
        let networkSession: any NetworkSessioning = URLSession.shared
        #endif

        let httpClient = AuthenticatingHTTPClient(
            baseURL: baseURL,
            tokenProvider: tokenProvider,
            session: networkSession
        )

        let pushDeviceService = PushDeviceService(
            client: httpClient,
            storage: pushDeviceStorage
        )

        let authService = AuthService(client: httpClient, tokenStorage: tokenStorage)
        let riderService = RiderService(client: httpClient)

        let authState = AuthState(
            authService: authService,
            riderService: riderService,
            tokenStorage: tokenStorage,
            pushDeviceService: pushDeviceService
        )

        Task { @MainActor in
            await httpClient.setSessionInvalidationHandler {
                await authState.handleSessionInvalidation()
            }
        }

        return AuthDependencies(
            httpClient: httpClient,
            authState: authState,
            pushDeviceService: pushDeviceService
        )
    }

    // MARK: - Services

    private struct Services {
        let rider: any RiderServiceProtocol
        let places: any PlacesServiceProtocol
        let sports: any SportsServiceProtocol
        let feed: any FeedServiceProtocol
    }

    private static func configureServices(httpClient: AuthenticatingHTTPClient) -> Services {
        Services(
            rider: RiderService(client: httpClient),
            places: PlacesService(client: httpClient),
            sports: SportsServiceService(client: httpClient),
            feed: FeedService(client: httpClient)
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
        pushDeviceService: any PushDeviceServiceProtocol,
        services: Services,
        chat: ChatDependencies
    ) {
        let container = DIContainer.shared
        container.register(AuthState.self) { authState }
        container.register(AuthenticatingHTTPClient.self) { httpClient }
        container.register(PushDeviceServiceProtocol.self) { pushDeviceService }
        container.register(RiderServiceProtocol.self) { services.rider }
        container.register(PlacesServiceProtocol.self) { services.places }
        container.register(ChatServiceProtocol.self) { chat.service }
        container.register(ChatRepository.self) { chat.repository }
        container.register(ChatLifecycleManager.self) { chat.lifecycleManager }
        container.register(ChatEventHandler.self) { chat.eventHandler }
    }
}
