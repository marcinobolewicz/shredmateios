import SwiftUI
import Core
import Networking
import Login
import Common
import Conversations
import Onboarding
import Profile
#if DEBUG
import PulseUI
#endif

public struct RootView: View {
    private var dependencies: AppDependencies
    @Environment(AuthState.self) private var authState
    @Environment(FollowRepository.self) private var followRepository
    @Environment(\.scenePhase) private var scenePhase
    @State private var router = RootRouter()
    @State private var appRouter: AppRouter = {
        let router = AppRouter()
        DIContainer.shared.register(AppRouter.self) { router }
        return router
    }()
    @State private var showWelcome = false
    @State private var sportsCount: Int = 0
    @State private var primarySportId: String?
    @State private var sportsLoaded = false
    @State private var parkedOnSplashForOnboarding = false
    @State private var sportsRetryInFlight = false
    @State private var pendingDeepLink: DeepLink?
    #if DEBUG
    @State private var showPulseConsole = false
    #endif

    public init(
        dependencies: AppDependencies
    ) {
        self.dependencies = dependencies
    }

    public var body: some View {
        ZStack {
            switch router.flow {
            case .loading:
                SplashView()

            case .guest:
                GuestTabView(
                    dependencies: dependencies,
                    onLoginTap: { router.showAuth(.login) }
                )

            case .auth(let entry):
                AuthFlowView(
                    entry: entry,
                    onClose: { router.showGuest() },
                    onLoginSuccess: routeAfterLogin
                )

            case .onboarding:
                OnboardingView(
                    sportsCount: sportsCount,
                    sportId: primarySportId,
                    riderService: dependencies.riderService,
                    onClose: dismissOnboarding,
                    onComplete: completeOnboarding(with:)
                )

            case .user:
                UserTabView(dependencies: dependencies)
            }

            if authState.isLoading { LoadingOverlay() }
        }
        .animation(.easeInOut(duration: 0.25), value: router.flow)
        .fullScreenCover(isPresented: $showWelcome, onDismiss: OnboardingStorage.markWelcomeShown) {
            WelcomeView(onAction: handleWelcomeAction)
        }
        .inAppNotificationOverlay(center: dependencies.notificationCenter)
        #if DEBUG
        .onShake { showPulseConsole = true }
        .onTapGesture(count: 3) { showPulseConsole = true }
        .sheet(isPresented: $showPulseConsole) {
            NavigationStack { ConsoleView() }
        }
        #endif
        .task {
            async let sportsTask: Void = loadSportsCount()
            await authState.restoreSession()
            await bootstrapInitialFlow()
            await sportsTask
        }
        .onChange(of: authState.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                routeAfterLogin()
                Task {
                    await connectChat()
                    await PushNotificationsBridge.requestAuthorizationAfterLogin()
                }
            } else {
                router.flow = .guest
                disconnectChat()
                followRepository.reset()
            }
        }
        .onChange(of: router.flow) { _, flow in
            if flow == .user {
                applyPendingDeepLink()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // When the app returns to the foreground, retry the sports
            // fetch if onboarding is still pending and we never got a
            // successful load. On success, `retrySportsIfNeeded()` flips
            // an already-on-home user into the onboarding flow.
            guard phase == .active else { return }
            Task { await retrySportsIfNeeded() }
        }
        .alert(
            CommonStrings.sessionExpiredTitle.localized,
            isPresented: Bindable(authState).sessionExpired
        ) {
            Button(CommonStrings.okButton.localized) {}
        } message: {
            Text(CommonStrings.sessionExpiredMessage.localized)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            guard
                let url = activity.webpageURL,
                let deepLink = UniversalLinkRouter.deepLink(from: url)
            else { return }

            handleIncomingDeepLink(deepLink)
        }
        .onOpenURL { url in
            guard let deepLink = UniversalLinkRouter.deepLink(from: url) else { return }
            handleIncomingDeepLink(deepLink)
        }
        .environment(router)
        .environment(appRouter)
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

    // MARK: - Boot

    /// Resolves the no-session branch of app startup.
    ///
    /// The logged-in branch is handled by `onChange(of: authState.isLoggedIn)`,
    /// which fires as soon as `restoreSession()` flips the state. This method
    /// therefore only runs when the restore did **not** find a session: we
    /// drop the splash for the guest tabs and, on a fresh install, raise the
    /// one-shot welcome cover.
    ///
    /// Keeping the splash visible for the full duration of `restoreSession()`
    /// is what eliminates the guest-to-user "blink".
    private func bootstrapInitialFlow() async {
        guard !authState.isLoggedIn else { return }
        router.flow = .guest
        // welcome initial flow
        if !OnboardingStorage.isWelcomeShown {
            showWelcome = true
        }
    }

    // MARK: - Post-login routing

    /// Routes the user after login or session restore. New registrations
    /// get `isPending` persisted so onboarding survives app restarts when
    /// the sports fetch fails. Onboarding only starts once sports metadata
    /// is loaded; otherwise we park on the splash and let
    /// `loadSportsCount()` or `retrySportsIfNeeded()` flip the flow.
    private func routeAfterLogin() {
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

    // MARK: - Deep Link Handling

    private func handleIncomingDeepLink(_ deepLink: DeepLink) {
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

    /// Closes onboarding via the X button. Marks the flow as completed,
    /// clears the freshly-registered flag and lands the user on the
    /// default home tab.
    private func dismissOnboarding() {
        finishOnboarding(deepLink: .home)
    }

    /// Routes the user out of onboarding into the right corner of the
    /// main app, based on the CTA they picked on the success step.
    private func completeOnboarding(with destination: OnboardingDestination) {
        finishOnboarding(deepLink: destination.deepLink)
    }

    private func finishOnboarding(deepLink: DeepLink) {
        OnboardingStorage.clearPending()
        authState.clearNewRegistration()
        appRouter.handle(deepLink)
        router.showUser()
    }

    /// Pre-loads the sports catalog so onboarding can pick the right
    /// variant. On success parks flip into `.onboarding`; on failure the
    /// user lands on `.user` and `isPending` stays set for retry.
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

    /// Retries the sports fetch on foreground if onboarding is still
    /// pending and we never got a successful load. On success flips
    /// an already-on-home user into onboarding.
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

    // MARK: - Welcome Flow

    /// Handles a user choice from the first-run welcome cover.
    ///
    /// The cover is always dismissed; `signUp`/`signIn` additionally kick
    /// off the auth flow, while `later` leaves the user on the guest tabs.
    private func handleWelcomeAction(_ action: WelcomeAction) {
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
}

private struct LoadingOverlay: View {
    var body: some View {
        Color.black.opacity(0.25)
            .ignoresSafeArea()
            .overlay {
                ProgressView()
                    .scaleEffect(1.2)
            }
    }
}
