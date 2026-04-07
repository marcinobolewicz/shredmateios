import SwiftUI
import Networking
import Login
import Common
import Conversations
import Onboarding
#if DEBUG
import PulseUI
#endif

public struct RootView: View {
    private var dependencies: AppDependencies
    @Environment(AuthState.self) private var authState
    @Environment(FollowRepository.self) private var followRepository
    @State private var router = RootRouter()
    @State private var showWelcome = false
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
                    onLoginSuccess: { router.showUser() }
                )

            case .onboarding:
                OnboardingView {
                    OnboardingStorage.markCompleted()
                    authState.clearNewRegistration()
                    router.showUser()
                }

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
            async let _ = dependencies.sportsService.fetchSports()
            await authState.restoreSession()
            await bootstrapInitialFlow()
        }
        .onChange(of: authState.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn && authState.isNewRegistration && !OnboardingStorage.isCompleted {
                router.showOnboarding()
            } else {
                router.flow = isLoggedIn ? .user : .guest
            }

            if isLoggedIn {
                Task {
                    await connectChat()
                    await PushNotificationsBridge.requestAuthorizationAfterLogin()
                }
            } else {
                disconnectChat()
                followRepository.reset()
            }
        }
        .alert(
            CommonStrings.sessionExpiredTitle.localized,
            isPresented: Bindable(authState).sessionExpired
        ) {
            Button(CommonStrings.okButton.localized) {}
        } message: {
            Text(CommonStrings.sessionExpiredMessage.localized)
        }
        .environment(router)
    }

    // MARK: - Chat Lifecycle

    private func connectChat() async {
        await dependencies.chatLifecycleManager.onAuthenticated()
        dependencies.chatEventHandler.startListening()
    }

    private func disconnectChat() {
        dependencies.chatLifecycleManager.onLogout()
        dependencies.chatEventHandler.stopListening()
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
        // welcome initiao flow 
//        if !OnboardingStorage.isWelcomeShown {
            showWelcome = true
//        }
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
