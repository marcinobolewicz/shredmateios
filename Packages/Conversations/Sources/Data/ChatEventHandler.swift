//
//  ChatEventHandler.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
import os.log

private let logger = Logger(subsystem: "com.shredmate.chat", category: "EventHandler")

/// Bridges the socket realtime event stream with ``ChatRepository``.
///
/// Iterates an `AsyncStream<ChatRealtimeEvent>` produced by the
/// ``ChatRealtimeProviding`` layer and forwards relevant events
/// to the repository for optimistic UI updates and cache invalidation.
///
/// ## Lifecycle
/// Call ``startListening()`` after authentication and socket connection.
/// Call ``stopListening()`` on logout or when the socket disconnects.
/// Starting a new listening session automatically cancels the previous one.
@MainActor
public final class ChatEventHandler {

    // MARK: - Dependencies

    private let realtimeClient: ChatRealtimeProviding
    private let repository: ChatRepository

    // MARK: - State

    private var listenerTask: Task<Void, Never>?

    // MARK: - Init

    public init(realtimeClient: ChatRealtimeProviding, repository: ChatRepository) {
        self.realtimeClient = realtimeClient
        self.repository = repository
    }

    // MARK: - Public API

    /// Starts iterating the realtime event stream.
    /// Cancels any previously active listener.
    public func startListening() {
        stopListening()

        listenerTask = Task { [weak self, realtimeClient] in
            logger.info("Event listener started")

            for await event in realtimeClient.events {
                guard let self, !Task.isCancelled else { break }
                handle(event)
            }

            logger.info("Event listener stopped")
        }
    }

    /// Cancels the active listener task.
    public func stopListening() {
        listenerTask?.cancel()
        listenerTask = nil
    }

    // MARK: - Event Dispatch

    private func handle(_ event: ChatRealtimeEvent) {
        switch event {
        case .connected(let socketId):
            logger.info("Socket connected — sid: \(socketId)")

        case .disconnected(let reason):
            logger.info("Socket disconnected — reason: \(reason)")

        case .connectionError(let message):
            logger.error("Socket connection error: \(message)")

        case .messageNew(let payload):
            repository.handleMessageNew(payload)

        case .conversationUpdated(let payload):
            repository.handleConversationUpdated(payload)

        case .messageAck(let payload):
            logger.debug("Message acknowledged: \(payload.messageId)")
            // ACK can be used for delivery confirmation UI in the future
        }
    }
}
