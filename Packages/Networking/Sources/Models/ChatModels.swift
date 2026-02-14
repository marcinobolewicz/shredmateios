//
//  ChatModels.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

// MARK: - Chat User

/// User visible in a conversation context
public struct ChatUser: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String?
    public let avatarUrl: String?
    public let email: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, avatarUrl, email
    }

    public init(
        id: String,
        name: String? = nil,
        avatarUrl: String? = nil,
        email: String? = nil
    ) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.email = email
    }
}

// MARK: - Rider Info (Sender Submodel)

/// Rider profile info embedded within ``MessageSender``
public struct RiderInfo: Codable, Sendable, Equatable {
    public let name: String?
    public let avatarUrl: String?

    private enum CodingKeys: String, CodingKey {
        case name, avatarUrl
    }

    public init(name: String? = nil, avatarUrl: String? = nil) {
        self.name = name
        self.avatarUrl = avatarUrl
    }
}

// MARK: - Message Sender

/// Sender embedded in a message, includes rider profile info
public struct MessageSender: Codable, Sendable, Equatable {
    public let id: String
    public let email: String
    public let rider: RiderInfo

    private enum CodingKeys: String, CodingKey {
        case id, email, rider
    }

    public init(id: String, email: String, rider: RiderInfo) {
        self.id = id
        self.email = email
        self.rider = rider
    }
}

// MARK: - Message Type

/// Discriminator for message content type
public enum MessageType: String, Codable, Sendable {
    case text = "TEXT"
    case image = "IMAGE"
}

// MARK: - Chat Message

/// A single message within a conversation
public struct ChatMessage: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let conversationId: String?
    public let senderId: String
    public let type: MessageType
    public let content: String
    public let createdAt: String
    public let sender: MessageSender?

    private enum CodingKeys: String, CodingKey {
        case id, conversationId, senderId, type, content, createdAt, sender
    }

    public init(
        id: String,
        conversationId: String? = nil,
        senderId: String,
        type: MessageType,
        content: String,
        createdAt: String,
        sender: MessageSender? = nil
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.type = type
        self.content = content
        self.createdAt = createdAt
        self.sender = sender
    }
}

// MARK: - Chat Conversation

/// A conversation between two users, including the last message preview
public struct ChatConversation: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let updatedAt: String
    public let lastMessageAt: String?
    public let lastMessage: ChatMessage?
    public let otherUser: ChatUser

    private enum CodingKeys: String, CodingKey {
        case id, updatedAt, lastMessageAt, lastMessage, otherUser
    }

    public init(
        id: String,
        updatedAt: String,
        lastMessageAt: String? = nil,
        lastMessage: ChatMessage? = nil,
        otherUser: ChatUser
    ) {
        self.id = id
        self.updatedAt = updatedAt
        self.lastMessageAt = lastMessageAt
        self.lastMessage = lastMessage
        self.otherUser = otherUser
    }
}
