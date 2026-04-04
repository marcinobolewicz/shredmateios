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
            router.flow = authState.isLoggedIn ? .user : .guest
        }
        .onChange(of: authState.isLoggedIn, initial: true) { _, isLoggedIn in
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

