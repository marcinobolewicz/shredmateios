import SwiftUI
import Auth
import Login

import SwiftUI

public struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(AuthState.self) private var authState
    @State private var router = RootRouter()

    public init() {}
    
    public var body: some View {
        ZStack {
            switch router.flow {
            case .guest:
                GuestTabView(onLoginTap: { router.showAuth(.login) })

            case .auth(let entry):
                AuthFlowView(
                    authState: authState,
                    entry: entry,
                    onClose: { router.showGuest() },
                    onLoginSuccess: { router.showUser() }
                )

            case .user:
                UserTabView(dependencies: dependencies)
            }

            if authState.isLoading { LoadingOverlay() }
        }
        .task {
            await authState.restoreSession()
            router.flow = authState.isLoggedIn ? .user : .guest
        }
        .onChange(of: authState.isLoggedIn) { _, isLoggedIn in
            router.flow = isLoggedIn ? .user : .guest
        }
        .environment(router)
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

