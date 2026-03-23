import SwiftUI
import Networking
import Login
import Conversations
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

            if authState.isLoggedIn {
                await connectChat()
                await PushNotificationsBridge.requestAuthorizationAfterLogin()
            }
        }
        .onChange(of: authState.isLoggedIn) { _, isLoggedIn in
            router.flow = isLoggedIn ? .user : .guest

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

