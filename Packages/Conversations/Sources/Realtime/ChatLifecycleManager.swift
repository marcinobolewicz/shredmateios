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
import UserNotifications
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
    private nonisolated(unsafe) var backgroundObserver: (any NSObjectProtocol)?

    // MARK: - Init

    public init(realtimeClient: ChatRealtimeProviding, authState: AuthState) {
        self.realtimeClient = realtimeClient
        self.authState = authState
        observeForeground()
        observeBackground()
    }

    deinit {
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Auth State Changes

    /// Call after a successful login / session restore.
    ///
    /// Fetches the current access token and opens the socket connection.
    /// No-op if no token is available (logged-out state).
    public func onAuthenticated() async {
        guard authState.isLoggedIn else {
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

    private func observeBackground() {
        #if canImport(UIKit)
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleBackgroundTransition()
            }
        }
        #endif
    }

    /// Disconnects the socket immediately when the app enters background.
    ///
    /// This ensures the backend marks the user as offline so APNs push
    /// notifications are delivered without the ~30 s delay that occurs
    /// while iOS keeps a suspended socket alive.
    private func handleBackgroundTransition() {
        guard lastToken != nil else { return }
        logger.info("App entering background — disconnecting socket for push delivery")
        realtimeClient.disconnect()
    }

    /// Runs when the app returns to the foreground.
    ///
    /// 1. Checks whether authentication is still valid.
    /// 2. If the token has been refreshed, reconnects the socket with the new token.
    /// 3. If the socket was simply disconnected (but token is OK), reconnects.
    private func handleForegroundResume() async {
        logger.info("App entering foreground — checking token & socket state")

        clearBadge()

        guard authState.isLoggedIn else {
            logger.debug("Not logged in on foreground — disconnecting socket")
            realtimeClient.disconnect()
            lastToken = nil
            return
        }

        // Proactively refresh tokens if they may be expired
        if await authState.tokensNeedRefresh() {
            logger.info("Tokens may be expired — refreshing session")
            let refreshed = await authState.refreshSessionIfNeeded()
            if !refreshed {
                logger.warning("Token refresh failed on foreground — disconnecting")
                realtimeClient.disconnect()
                lastToken = nil
                return
            }
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

    // MARK: - Badge

    private func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error {
                logger.warning("Failed to clear badge: \(error.localizedDescription)")
            }
        }
    }
}
