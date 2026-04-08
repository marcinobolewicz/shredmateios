//
//  ChatEventHandler.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
import Networking
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

    /// Current user's ID. Required so the handler can distinguish messages from
    /// the current user (which should not increment `unreadCount` nor trigger
    /// an auto mark-as-read) from messages received from others.
    /// Update via ``setCurrentUserId(_:)`` on login / logout.
    private var currentUserId: String?

    /// Callback invoked when a new message arrives via socket.
    /// The App layer sets this to post an in-app notification banner.
    public var onMessageReceived: ((_ senderName: String, _ text: String, _ conversationId: String) -> Void)?

    // MARK: - Init

    public init(realtimeClient: ChatRealtimeProviding, repository: ChatRepository) {
        self.realtimeClient = realtimeClient
        self.repository = repository
    }

    // MARK: - User Session

    /// Sets (or clears, via `nil`) the currently signed-in user ID.
    public func setCurrentUserId(_ userId: String?) {
        currentUserId = userId
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

            // Scenario B: if the chat screen for this conversation is open,
            // immediately mark it as read so no badge flickers into existence.
            let isFromMe = payload.senderId == currentUserId
            let isCurrentlyOpen = repository.currentConversationId == payload.conversationId
            if !isFromMe && isCurrentlyOpen {
                Task { [weak repository] in
                    await repository?.markAsRead(conversationId: payload.conversationId)
                }
            }

            // Only surface banners for messages from other users.
            guard !isFromMe else { return }
            let senderName = repository.conversations
                .first(where: { $0.id == payload.conversationId })?
                .otherUser.name
            let preview = payload.text ?? ""
            onMessageReceived?(senderName ?? "", preview, payload.conversationId)

        case .conversationUpdated(let payload):
            repository.handleConversationUpdated(payload, currentUserId: currentUserId ?? "")

        case .conversationRead(let payload):
            repository.handleConversationRead(payload)

        case .messageAck(let payload):
            logger.debug("Message acknowledged: \(payload.messageId)")
            // ACK can be used for delivery confirmation UI in the future
        }
    }
}
