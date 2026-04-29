//
//  ChatSocketPayloads.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

// MARK: - message:new

/// Payload received from Socket.IO `message:new` event.
///
/// Content is a discriminated union on `type`:
/// - `.text` → `text` is populated
/// - `.image` → `imageUrl` is populated
public struct MessageNewPayload: Decodable, Sendable, Equatable {
    public let id: String
    public let conversationId: String
    public let senderId: String
    public let createdAt: String
    public let type: MessageType
    public let text: String?
    public let imageUrl: String?

    private enum CodingKeys: String, CodingKey {
        case id, conversationId, senderId, createdAt, type, text, imageUrl
    }

    public init(
        id: String,
        conversationId: String,
        senderId: String,
        createdAt: String,
        type: MessageType,
        text: String? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.createdAt = createdAt
        self.type = type
        self.text = text
        self.imageUrl = imageUrl
    }
}

// MARK: - conversation:updated

/// Payload received from Socket.IO `conversation:updated` event
public struct ConversationUpdatedPayload: Decodable, Sendable, Equatable {
    public let conversationId: String
    public let otherUserId: String
    public let lastMessageAt: String?
    public let lastMessage: MessageNewPayload?

    private enum CodingKeys: String, CodingKey {
        case conversationId, otherUserId, lastMessageAt, lastMessage
    }

    public init(
        conversationId: String,
        otherUserId: String,
        lastMessageAt: String? = nil,
        lastMessage: MessageNewPayload? = nil
    ) {
        self.conversationId = conversationId
        self.otherUserId = otherUserId
        self.lastMessageAt = lastMessageAt
        self.lastMessage = lastMessage
    }
}

// MARK: - conversation:read

/// Payload received from Socket.IO `conversation:read` event.
///
/// Emitted to the sender when the other participant marks the
/// conversation as read. Use `lastReadAt` to render "seen" indicators
/// on messages whose `createdAt <= lastReadAt`.
public struct ConversationReadPayload: Decodable, Sendable, Equatable {
    public let conversationId: String
    public let readerId: String
    public let lastReadAt: String

    private enum CodingKeys: String, CodingKey {
        case conversationId, readerId, lastReadAt
    }

    public init(conversationId: String, readerId: String, lastReadAt: String) {
        self.conversationId = conversationId
        self.readerId = readerId
        self.lastReadAt = lastReadAt
    }
}

// MARK: - message:ack

/// Payload received from Socket.IO `message:ack` event
public struct MessageAckPayload: Decodable, Sendable, Equatable {
    public let messageId: String
    public let conversationId: String
    public let createdAt: String

    private enum CodingKeys: String, CodingKey {
        case messageId, conversationId, createdAt
    }

    public init(
        messageId: String,
        conversationId: String,
        createdAt: String
    ) {
        self.messageId = messageId
        self.conversationId = conversationId
        self.createdAt = createdAt
    }
}

// MARK: - Payload → ChatMessage Conversion

extension MessageNewPayload {
    /// Converts a socket payload into a `ChatMessage`.
    ///
    /// The socket does not provide full sender data, so `sender`
    /// is populated with a placeholder. REST re-fetch will supply
    /// complete sender info via cache invalidation.
    public func toChatMessage() -> ChatMessage {
        let content: String = {
            switch type {
            case .text:  return text ?? ""
            case .image: return imageUrl ?? ""
            }
        }()

        return ChatMessage(
            id: id,
            conversationId: conversationId,
            senderId: senderId,
            type: type,
            content: content,
            createdAt: createdAt,
            sender: MessageSender(
                id: senderId,
                email: "",
                rider: .init(name: nil, avatarUrl: nil)
            )
        )
    }
}
