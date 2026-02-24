//
//  ChatRepository.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
import Networking
import os.log

private let logger = Logger(subsystem: "com.shredmate.chat", category: "Repository")

/// Central state manager for conversations and messages.
///
/// ## Responsibilities
/// - Cursor-based pagination for conversations and messages.
/// - Optimistic insertion of messages from REST responses and socket events.
/// - Deduplication of messages and conversations by `id`.
/// - Cache invalidation (re-fetch from REST) after every socket event or mutation
///   — REST is the source of truth, socket only accelerates the UI.
///
/// ## Threading
/// All state mutations happen on `@MainActor` so SwiftUI can observe
/// changes instantly without manual dispatching.
@MainActor
@Observable
public final class ChatRepository {

    // MARK: - Published State — Conversations

    /// Conversations sorted by `lastMessageAt` descending (newest first).
    public private(set) var conversations: [ChatConversation] = []
    public private(set) var isLoadingConversations = false
    public private(set) var hasMoreConversations = true
    public private(set) var conversationsError: Error?

    // MARK: - Published State — Messages

    /// Messages keyed by `conversationId`, stored **oldest-first** for UI display.
    public private(set) var messagesByConversation: [String: [ChatMessage]] = [:]
    public private(set) var isLoadingMessages: [String: Bool] = [:]
    public private(set) var hasMoreMessages: [String: Bool] = [:]
    public private(set) var messagesError: [String: Error] = [:]

    // MARK: - Dependencies

    private let chatService: ChatServiceProtocol
    private let pageSize: Int

    // MARK: - Pagination Cursors (private)

    private var conversationsCursor: String?
    private var messagesCursors: [String: String] = [:]

    // MARK: - Init

    public init(chatService: ChatServiceProtocol, pageSize: Int = 20) {
        self.chatService = chatService
        self.pageSize = min(max(pageSize, 1), 100)
    }

    // MARK: - Conversations — Load

    /// Loads conversations. Pass `refresh: true` to discard existing data
    /// and start from the first page.
    public func loadConversations(refresh: Bool = false) async {
        guard !isLoadingConversations else { return }

        if refresh {
            conversationsCursor = nil
            hasMoreConversations = true
        }
        guard hasMoreConversations else { return }

        isLoadingConversations = true
        conversationsError = nil
        defer { isLoadingConversations = false }

        do {
            let params = PaginationParams(take: pageSize, cursor: conversationsCursor)
            let page = try await chatService.listConversations(params: params)

            if refresh {
                conversations = page
            } else {
                appendConversations(page)
            }

            conversationsCursor = page.last?.id
            hasMoreConversations = page.count >= pageSize

            logger.debug("Loaded \(page.count) conversations (hasMore: \(self.hasMoreConversations))")
        } catch {
            conversationsError = error
            logger.error("Failed to load conversations: \(error.localizedDescription)")
        }
    }

    /// Convenience: loads the next page of conversations (infinite scroll).
    public func loadNextConversationsPage() async {
        await loadConversations(refresh: false)
    }

    // MARK: - Conversations — Open / Create

    /// Opens an existing conversation with `otherUserId` or creates a new one.
    /// After success, invalidates the conversations list.
    ///
    /// - Returns: The opened or newly created conversation.
    @discardableResult
    public func openOrCreateConversation(otherUserId: String) async throws -> ChatConversation {
        let conversation = try await chatService.openOrCreateConversation(otherUserId: otherUserId)
        await loadConversations(refresh: true)
        return conversation
    }

    // MARK: - Messages — Load

    /// Loads messages for a conversation. Pass `refresh: true` to start from
    /// the newest page; `false` to load older messages (infinite scroll up).
    public func loadMessages(for conversationId: String, refresh: Bool = false) async {
        guard isLoadingMessages[conversationId] != true else { return }

        if refresh {
            messagesCursors[conversationId] = nil
            hasMoreMessages[conversationId] = true
        }
        guard hasMoreMessages[conversationId] != false else { return }

        isLoadingMessages[conversationId] = true
        messagesError[conversationId] = nil
        defer { isLoadingMessages[conversationId] = false }

        do {
            let params = PaginationParams(take: pageSize, cursor: messagesCursors[conversationId])
            let page = try await chatService.getMessages(conversationId: conversationId, params: params)

            // API returns newest-first; UI needs oldest-first → reverse
            let oldestFirst = Array(page.reversed())

            if refresh {
                messagesByConversation[conversationId] = oldestFirst
            } else {
                // Loading older messages → prepend before existing
                prependMessages(oldestFirst, for: conversationId)
            }

            // Cursor points to the last element in the API response (oldest in that page)
            messagesCursors[conversationId] = page.last?.id
            hasMoreMessages[conversationId] = page.count >= pageSize

            logger.debug("Loaded \(page.count) messages for \(conversationId) (hasMore: \(self.hasMoreMessages[conversationId] ?? false))")
        } catch {
            messagesError[conversationId] = error
            logger.error("Failed to load messages for \(conversationId): \(error.localizedDescription)")
        }
    }

    /// Convenience: loads the next (older) page for a conversation.
    public func loadOlderMessages(for conversationId: String) async {
        await loadMessages(for: conversationId, refresh: false)
    }

    // MARK: - Messages — Send

    /// Sends a text message and optimistically appends it to the cache.
    /// Invalidates both messages and conversations after success.
    public func sendMessage(conversationId: String, text: String) async throws -> ChatMessage {
        let message = try await chatService.sendMessage(
            conversationId: conversationId,
            input: .text(text)
        )

        // Optimistic insert (oldest-first → append at end)
        appendMessageIfNew(message, for: conversationId)

        // Invalidate for consistency
        await loadConversations(refresh: true)

        return message
    }

    // MARK: - Socket Event Handling

    /// Handles a `message:new` socket event.
    ///
    /// 1. Converts payload to `ChatMessage` (with placeholder sender).
    /// 2. Optimistically inserts into the message cache (deduplicated).
    /// 3. Invalidates both messages and conversations via REST re-fetch.
    public func handleMessageNew(_ payload: MessageNewPayload) {
        let message = payload.toChatMessage()
        let conversationId = payload.conversationId
        appendMessageIfNew(message, for: conversationId)

        Task { [weak self] in
            await self?.loadMessages(for: conversationId, refresh: true)
            await self?.loadConversations(refresh: true)
        }
    }

    /// Handles a `conversation:updated` socket event.
    ///
    /// 1. If conversation exists in cache — moves it to the top.
    /// 2. Invalidates conversations and the affected conversation's messages.
    public func handleConversationUpdated(_ payload: ConversationUpdatedPayload) {
        moveConversationToTop(payload.conversationId)

        Task { [weak self] in
            await self?.loadConversations(refresh: true)
            await self?.loadMessages(for: payload.conversationId, refresh: true)
        }
    }

    /// Returns current messages for a conversation (oldest-first).
    public func messages(for conversationId: String) -> [ChatMessage] {
        messagesByConversation[conversationId] ?? []
    }

    // MARK: - Private Helpers

    /// Appends conversations while deduplicating by `id`.
    private func appendConversations(_ newItems: [ChatConversation]) {
        let existingIds = Set(conversations.map(\.id))
        let unique = newItems.filter { !existingIds.contains($0.id) }
        conversations.append(contentsOf: unique)
    }

    /// Prepends older messages (oldest-first) before the existing cache,
    /// deduplicating by `id`.
    private func prependMessages(_ olderMessages: [ChatMessage], for conversationId: String) {
        var existing = messagesByConversation[conversationId] ?? []
        let existingIds = Set(existing.map(\.id))
        let unique = olderMessages.filter { !existingIds.contains($0.id) }
        existing.insert(contentsOf: unique, at: 0)
        messagesByConversation[conversationId] = existing
    }

    /// Appends a single message at the end (newest) if not already in cache.
    private func appendMessageIfNew(_ message: ChatMessage, for conversationId: String) {
        var messages = messagesByConversation[conversationId] ?? []
        guard !messages.contains(where: { $0.id == message.id }) else { return }
        messages.append(message)
        messagesByConversation[conversationId] = messages
    }

    /// Moves a conversation to the top of the list (index 0).
    private func moveConversationToTop(_ conversationId: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        let conversation = conversations.remove(at: index)
        conversations.insert(conversation, at: 0)
    }
}
