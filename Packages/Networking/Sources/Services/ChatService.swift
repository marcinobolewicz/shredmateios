//
//  ChatService.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

// MARK: - Protocol

/// Abstraction over chat REST operations.
///
/// Inject ``ChatServiceProtocol`` into repositories/view-models
/// so they can be tested with a mock implementation.
public protocol ChatServiceProtocol: Sendable {

    /// Fetches a paginated list of the current user's conversations.
    ///
    /// Conversations are returned sorted by `lastMessageAt` descending (newest first).
    func listConversations(params: PaginationParams) async throws -> [ChatConversation]

    /// Opens an existing conversation with `otherUserId`, or creates one if none exists.
    ///
    /// - Parameter otherUserId: The **User** ID (not Rider profile ID).
    func openOrCreateConversation(otherUserId: String) async throws -> ChatConversation

    /// Fetches a paginated list of messages for a conversation.
    ///
    /// - Important: Messages are returned **newest-first** from the API.
    ///   The caller is responsible for reversing order if displaying oldest-first.
    func getMessages(conversationId: String, params: PaginationParams) async throws -> [ChatMessage]

    /// Sends a text message to the given conversation.
    func sendMessage(conversationId: String, input: SendMessageInput) async throws -> ChatMessage

    /// Marks a conversation as read for the current user.
    ///
    /// Idempotent — safe to call multiple times, including when there are no unread messages.
    ///
    /// - Returns: Server-side `lastReadAt` ISO-8601 timestamp.
    @discardableResult
    func markAsRead(conversationId: String) async throws -> String

    /// Deletes a conversation (cascades to messages and participations).
    ///
    /// - Throws: A network error if the caller is not a participant (HTTP 403).
    func deleteConversation(conversationId: String) async throws
}

// MARK: - Implementation

/// Concrete ``ChatServiceProtocol`` backed by an ``APIClienting`` HTTP client.
///
/// Authentication (Bearer token injection, 401 → refresh → retry)
/// is handled transparently by the underlying `APIClienting` implementation.
public final class ChatService: ChatServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func listConversations(params: PaginationParams) async throws -> [ChatConversation] {
        let response = try await client.send(
            ChatAPI.conversations(take: params.take, cursor: params.cursor)
        )
        return response.items
    }

    public func openOrCreateConversation(otherUserId: String) async throws -> ChatConversation {
        try await client.send(ChatAPI.openOrCreate(otherUserId: otherUserId))
    }

    public func getMessages(conversationId: String, params: PaginationParams) async throws -> [ChatMessage] {
        let response = try await client.send(
            ChatAPI.messages(conversationId: conversationId, take: params.take, cursor: params.cursor)
        )
        return response.items
    }

    public func sendMessage(conversationId: String, input: SendMessageInput) async throws -> ChatMessage {
        try await client.send(
            ChatAPI.sendMessage(conversationId: conversationId, input: input)
        )
    }

    @discardableResult
    public func markAsRead(conversationId: String) async throws -> String {
        let response = try await client.send(
            ChatAPI.markAsRead(conversationId: conversationId)
        )
        return response.lastReadAt
    }

    public func deleteConversation(conversationId: String) async throws {
        _ = try await client.send(
            ChatAPI.deleteConversation(conversationId: conversationId)
        )
    }
}
