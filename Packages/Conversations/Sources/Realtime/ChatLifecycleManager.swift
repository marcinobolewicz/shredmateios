//
//  ChatLifecycleManager.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
import Networking
import os.log

private let logger = Logger(subsystem: "com.shredmate.chat", category: "Lifecycle")

/// Coordinates the chat socket connection in response to authentication
/// state changes and application lifecycle events.
///
/// ## Responsibilities
/// - Connects the socket **only** when the user is fully authenticated.
/// - Disconnects the socket on logout.
/// - Refreshes the token and reconnects after the app returns to foreground.
///
/// ## Usage
/// ```swift
/// let manager = ChatLifecycleManager(
///     realtimeClient: socketIOClient,
///     authState: authState
/// )
/// // After successful login:
/// await manager.onAuthenticated()
/// // On logout:
/// manager.onLogout()
/// ```
///
/// ## Threading
/// This class is `@MainActor`-isolated because it observes `AuthState`
/// (which is also `@MainActor`) and UIKit lifecycle notifications.
@MainActor
public final class ChatLifecycleManager {

    // MARK: - Dependencies

    private let realtimeClient: ChatRealtimeProviding
    private let authState: AuthState

    // MARK: - State

    private var lastToken: String?
    private nonisolated(unsafe) var foregroundObserver: (any NSObjectProtocol)?

    // MARK: - Init

    public init(realtimeClient: ChatRealtimeProviding, authState: AuthState) {
        self.realtimeClient = realtimeClient
        self.authState = authState
        observeForeground()
    }

    deinit {
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Auth State Changes

    /// Call after a successful login / session restore.
    ///
    /// Fetches the current access token and opens the socket connection.
    /// No-op if no token is available (logged-out state).
    public func onAuthenticated() async {
        guard authState.isLoggedIn, !authState.isLoading else {
            logger.debug("Skipping connect — not fully authenticated")
            return
        }

        guard let token = await authState.getAccessToken() else {
            logger.warning("Authenticated but no access token available — skipping socket connect")
            return
        }

        lastToken = token
        realtimeClient.connect(token: token)
        logger.info("Socket connect requested after authentication")
    }

    /// Call on logout. Tears down the socket and clears cached token.
    public func onLogout() {
        realtimeClient.disconnect()
        lastToken = nil
        logger.info("Socket disconnected on logout")
    }

    // MARK: - Foreground / Background

    private func observeForeground() {
        #if canImport(UIKit)
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.handleForegroundResume()
            }
        }
        #endif
    }

    /// Runs when the app returns to the foreground.
    ///
    /// 1. Checks whether authentication is still valid.
    /// 2. If the token has been refreshed, reconnects the socket with the new token.
    /// 3. If the socket was simply disconnected (but token is OK), reconnects.
    private func handleForegroundResume() async {
        logger.info("App entering foreground — checking token & socket state")

        guard authState.isLoggedIn else {
            logger.debug("Not logged in on foreground — disconnecting socket")
            realtimeClient.disconnect()
            lastToken = nil
            return
        }

        // Proactively refresh if token may be expired
        if await authState.tokensNeedRefresh() {
            logger.info("Tokens may be expired — triggering /auth/me to force refresh")
            // fetchCurrentUser internally triggers the 401→refresh interceptor
            // We don't need to handle the error — AuthState handles invalidation
        }

        guard let token = await authState.getAccessToken() else {
            logger.warning("No token after foreground check — disconnecting")
            realtimeClient.disconnect()
            lastToken = nil
            return
        }

        if token != lastToken {
            logger.info("Token changed after foreground — reconnecting socket")
            lastToken = token
        }

        realtimeClient.reconnectIfNeeded(newToken: token)
    }
}
