//
//  ChatRealtimeProviding.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

/// Abstraction over the chat realtime transport (Socket.IO).
///
/// Inject this protocol into managers/repositories to decouple them
/// from the concrete Socket.IO implementation, enabling easy mocking
/// and unit testing.
///
/// ## Lifecycle
/// 1. Call ``connect(token:)`` after the user is authenticated.
/// 2. Iterate ``events`` to react to incoming messages and status changes.
/// 3. Call ``reconnectIfNeeded(newToken:)`` when the access token changes
///    (e.g., after a JWT refresh or foreground resume).
/// 4. Call ``disconnect()`` on logout or when the user is no longer authenticated.
///
/// ## Threading
/// Implementations must be safe to call from any actor/thread.
/// The ``events`` stream must deliver values that are ``Sendable``.
public protocol ChatRealtimeProviding: Sendable {

    /// Whether the socket is currently connected.
    var isConnected: Bool { get }

    /// Opens a socket connection authenticated with the given JWT.
    ///
    /// - Parameter token: A valid `accessToken` for the handshake.
    func connect(token: String)

    /// Tears down the socket connection and releases resources.
    func disconnect()

    /// Reconnects only if the token has changed since the last connection,
    /// or if the socket is not currently connected.
    ///
    /// - Parameter newToken: The (possibly refreshed) `accessToken`.
    func reconnectIfNeeded(newToken: String)

    /// A single long-lived stream of ``ChatRealtimeEvent`` values.
    ///
    /// The stream lives for the lifetime of the provider instance.
    /// Only one consumer should iterate the stream at a time.
    /// Reconnections reuse the same stream so consumers are never interrupted.
    var events: AsyncStream<ChatRealtimeEvent> { get }
}
