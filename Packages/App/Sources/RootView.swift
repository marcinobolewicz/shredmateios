import SwiftUI
import Networking
import Login
import Common
import Onboarding
#if DEBUG
import PulseUI
#endif

public struct RootView: View {
    @Environment(AuthState.self) private var authState
    @Environment(\.scenePhase) private var scenePhase
    @State private var coordinator: RootCoordinator
    #if DEBUG
    @State private var showPulseConsole = false
    #endif

    public init(dependencies: AppDependencies) {
        _coordinator = State(initialValue: RootCoordinator(dependencies: dependencies))
    }

    public var body: some View {
        ZStack {
            switch coordinator.router.flow {
            case .loading:
                SplashView()

            case .guest:
                GuestTabView(
                    dependencies: coordinator.dependencies,
                    onLoginTap: { coordinator.router.showAuth(.login) }
                )

            case .auth(let entry):
                AuthFlowView(
                    entry: entry,
                    onClose: { coordinator.router.showGuest() },
                    onLoginSuccess: coordinator.routeAfterLogin
                )

            case .onboarding:
                OnboardingView(
                    sportsCount: coordinator.sportsCount,
                    sportId: coordinator.primarySportId,
                    riderService: coordinator.dependencies.riderService,
                    onClose: coordinator.dismissOnboarding,
                    onComplete: coordinator.completeOnboarding(with:)
                )

            case .user:
                UserTabView(dependencies: coordinator.dependencies)
            }

            if authState.isLoading { LoadingOverlay() }
        }
        .animation(.easeInOut(duration: 0.25), value: coordinator.router.flow)
        .fullScreenCover(
            isPresented: Bindable(coordinator).showWelcome,
            onDismiss: OnboardingStorage.markWelcomeShown
        ) {
            WelcomeView(onAction: coordinator.handleWelcomeAction)
        }
        // Blocking re-acceptance of updated legal documents (dismisses only
        // after accepting, or by declining — which logs the user out).
        .fullScreenCover(isPresented: .init(
            get: { !authState.pendingLegalDocuments.isEmpty },
            set: { _ in }
        )) {
            LegalAcceptanceView()
        }
        .inAppNotificationOverlay(center: coordinator.dependencies.notificationCenter)
        #if DEBUG
        .onShake { showPulseConsole = true }
        .onTapGesture(count: 3) { showPulseConsole = true }
        .sheet(isPresented: $showPulseConsole) {
            NavigationStack { ConsoleView() }
        }
        #endif
        .task { await coordinator.bootstrap() }
        .onChange(of: authState.isLoggedIn) { _, isLoggedIn in
            coordinator.handleAuthChange(isLoggedIn: isLoggedIn)
        }
        .onChange(of: coordinator.router.flow) { _, flow in
            coordinator.handleFlowChange(flow)
        }
        .onChange(of: scenePhase) { _, phase in
            coordinator.handleScenePhase(phase)
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
            guard let url = activity.webpageURL else { return }
            coordinator.handleIncomingURL(url)
        }
        .onOpenURL { url in
            coordinator.handleIncomingURL(url)
        }
        .environment(coordinator.router)
        .environment(coordinator.appRouter)
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
