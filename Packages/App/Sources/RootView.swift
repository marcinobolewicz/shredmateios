import SwiftUI
import Networking
import Login

import SwiftUI

public struct RootView: View {
    private var dependencies: AppDependencies
    @Environment(AuthState.self) private var authState
    @State private var router = RootRouter()

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

