//
//  ChatAPI.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

/// REST endpoint definitions for the chat module.
///
/// All endpoints require `Authorization: Bearer <accessToken>`.
/// List endpoints use ``FlexibleArray`` to handle both bare-array
/// and `{ "data": [...] }` response shapes.
public enum ChatAPI {

    // MARK: - Conversations

    /// Lists conversations for the current user (cursor-based pagination).
    ///
    /// `GET /chat/conversations?take=<take>&cursor=<cursor>`
    ///
    /// - Parameters:
    ///   - take: Number of items per page (clamped to 1...100).
    ///   - cursor: ID of the last conversation from the previous page.
    /// - Returns: Endpoint returning conversations sorted by `lastMessageAt` descending.
    public static func conversations(
        take: Int = 20,
        cursor: String? = nil
    ) -> Endpoint<FlexibleArray<ChatConversation>> {
        var query: [URLQueryItem] = [
            URLQueryItem(name: "take", value: "\(min(max(take, 1), 100))")
        ]
        if let cursor {
            query.append(URLQueryItem(name: "cursor", value: cursor))
        }
        return .get("/chat/conversations", query: query, auth: .bearerToken)
    }

    /// Opens an existing conversation with the given user, or creates a new one.
    ///
    /// `POST /chat/conversations/with/:otherUserId`
    ///
    /// - Parameter otherUserId: The **User** ID (not Rider profile ID) of the other participant.
    /// - Returns: Endpoint returning the opened or newly created conversation.
    public static func openOrCreate(otherUserId: String) -> Endpoint<ChatConversation> {
        .post("/chat/conversations/with/\(otherUserId)", auth: .bearerToken)
    }

    /// Marks a conversation as read for the current user.
    ///
    /// `POST /chat/conversations/:conversationId/read`
    ///
    /// Idempotent — safe to call multiple times.
    ///
    /// - Parameter conversationId: The conversation to mark as read.
    /// - Returns: Endpoint returning the updated `lastReadAt` timestamp.
    public static func markAsRead(conversationId: String) -> Endpoint<MarkAsReadResponse> {
        .post(
            "/chat/conversations/\(conversationId)/read",
            auth: .bearerToken
        )
    }

    /// Deletes a conversation (cascades to messages and participations).
    ///
    /// `DELETE /chat/conversations/:conversationId`
    ///
    /// - Parameter conversationId: The conversation to delete.
    /// - Returns: Endpoint returning an empty response.
    public static func deleteConversation(conversationId: String) -> Endpoint<EmptyResponse> {
        .delete(
            "/chat/conversations/\(conversationId)",
            auth: .bearerToken
        )
    }

    // MARK: - Messages

    /// Lists messages in a conversation (cursor-based pagination).
    ///
    /// `GET /chat/conversations/:conversationId/messages?take=<take>&cursor=<cursor>`
    ///
    /// - Important: The API returns messages **newest-first**. The caller is responsible
    ///   for reversing the order if the UI displays oldest-first.
    ///
    /// - Parameters:
    ///   - conversationId: The conversation to fetch messages for.
    ///   - take: Number of items per page (clamped to 1...100).
    ///   - cursor: ID of the last message from the previous page.
    /// - Returns: Endpoint returning messages sorted by `createdAt` descending.
    public static func messages(
        conversationId: String,
        take: Int = 20,
        cursor: String? = nil
    ) -> Endpoint<FlexibleArray<ChatMessage>> {
        var query: [URLQueryItem] = [
            URLQueryItem(name: "take", value: "\(min(max(take, 1), 100))")
        ]
        if let cursor {
            query.append(URLQueryItem(name: "cursor", value: cursor))
        }
        return .get(
            "/chat/conversations/\(conversationId)/messages",
            query: query,
            auth: .bearerToken
        )
    }

    /// Sends a text message to a conversation.
    ///
    /// `POST /chat/conversations/:conversationId/messages`
    ///
    /// - Parameters:
    ///   - conversationId: The target conversation.
    ///   - input: The message content (currently only `.text` is supported).
    /// - Returns: Endpoint returning the newly created message.
    public static func sendMessage(
        conversationId: String,
        input: SendMessageInput
    ) -> Endpoint<ChatMessage> {
        .post(
            "/chat/conversations/\(conversationId)/messages",
            body: input,
            auth: .bearerToken
        )
    }
}
