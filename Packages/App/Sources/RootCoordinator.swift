import SwiftUI
import Core
import Networking
import Conversations
import Onboarding

@MainActor
@Observable
final class RootCoordinator {

    let dependencies: AppDependencies
    let router = RootRouter()
    let appRouter: AppRouter

    var showWelcome = false
    private(set) var sportsCount: Int = 0
    private(set) var primarySportId: String?
    private var sportsLoaded = false
    private var parkedOnSplashForOnboarding = false
    private var sportsRetryInFlight = false
    private var pendingDeepLink: DeepLink?

    private var authState: AuthState { dependencies.authState }

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        let appRouter = AppRouter()
        DIContainer.shared.register(AppRouter.self) { appRouter }
        self.appRouter = appRouter
    }

    // MARK: - Bootstrap

    func bootstrap() async {
        async let sportsTask: Void = loadSportsCount()
        await authState.restoreSession()
        await bootstrapInitialFlow()
        await sportsTask
    }

    private func bootstrapInitialFlow() async {
        guard !authState.isLoggedIn else { return }
        router.flow = .guest
        if !OnboardingStorage.isWelcomeShown {
            showWelcome = true
        }
    }

    // MARK: - Auth Changes

    func handleAuthChange(isLoggedIn: Bool) {
        if isLoggedIn {
            routeAfterLogin()
            Task {
                await connectChat()
                await PushNotificationsBridge.requestAuthorizationAfterLogin()
            }
        } else {
            router.flow = .guest
            disconnectChat()
            dependencies.followRepository.reset()
        }
    }

    // MARK: - Post-login routing

    func routeAfterLogin() {
        guard authState.isLoggedIn else { return }

        if authState.isNewRegistration {
            OnboardingStorage.markPending()
        }

        if OnboardingStorage.isPending {
            if sportsLoaded {
                router.showOnboarding()
            } else {
                parkedOnSplashForOnboarding = true
                router.flow = .loading
            }
        } else {
            router.showUser()
        }
    }

    // MARK: - Flow Changes

    func handleFlowChange(_ flow: RootFlow) {
        if flow == .user {
            applyPendingDeepLink()
        }
    }

    // MARK: - Scene Phase

    func handleScenePhase(_ phase: ScenePhase) {
        guard phase == .active else { return }
        Task { await retrySportsIfNeeded() }
    }

    // MARK: - Deep Link

    func handleIncomingURL(_ url: URL) {
        guard let deepLink = UniversalLinkRouter.deepLink(from: url) else { return }
        if authState.isLoggedIn && router.flow == .user {
            appRouter.handle(deepLink)
        } else {
            pendingDeepLink = deepLink
        }
    }

    private func applyPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        appRouter.handle(deepLink)
    }

    // MARK: - Onboarding

    func dismissOnboarding() {
        finishOnboarding(deepLink: .home)
    }

    func completeOnboarding(with destination: OnboardingDestination) {
        finishOnboarding(deepLink: destination.deepLink)
    }

    private func finishOnboarding(deepLink: DeepLink) {
        OnboardingStorage.clearPending()
        authState.clearNewRegistration()
        appRouter.handle(deepLink)
        router.showUser()
    }

    private func loadSportsCount() async {
        let sports = try? await dependencies.sportsService.fetchSports()
        if let sports {
            sportsCount = sports.count
            primarySportId = sports.first?.id.uuidString
            sportsLoaded = true
        }

        guard parkedOnSplashForOnboarding else { return }
        parkedOnSplashForOnboarding = false
        if sportsLoaded {
            router.showOnboarding()
        } else {
            router.showUser()
        }
    }

    private func retrySportsIfNeeded() async {
        guard
            OnboardingStorage.isPending,
            !sportsLoaded,
            !sportsRetryInFlight,
            authState.isLoggedIn
        else { return }

        sportsRetryInFlight = true
        defer { sportsRetryInFlight = false }

        guard let sports = try? await dependencies.sportsService.fetchSports() else { return }
        sportsCount = sports.count
        primarySportId = sports.first?.id.uuidString
        sportsLoaded = true

        guard
            OnboardingStorage.isPending,
            authState.isLoggedIn,
            router.flow == .user
        else { return }
        router.showOnboarding()
    }

    // MARK: - Welcome

    func handleWelcomeAction(_ action: WelcomeAction) {
        showWelcome = false
        switch action {
        case .signUp:
            router.showAuth(.register)
        case .signIn:
            router.showAuth(.login)
        case .later:
            break
        }
    }

    // MARK: - Chat Lifecycle

    private func connectChat() async {
        await dependencies.chatLifecycleManager.onAuthenticated()
        dependencies.chatEventHandler.setCurrentUserId(authState.user?.id)
        dependencies.chatEventHandler.startListening()
        await dependencies.chatRepository.loadConversations(refresh: true)
    }

    private func disconnectChat() {
        dependencies.chatLifecycleManager.onLogout()
        dependencies.chatEventHandler.stopListening()
        dependencies.chatEventHandler.setCurrentUserId(nil)
    }
}
