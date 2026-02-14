//
//  Conversation.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

public struct Conversation: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let participant: ConversationParticipant
    public let lastMessageText: String?
    public let lastMessageDate: Date?
    public let unreadCount: Int

    public init(
        id: UUID,
        participant: ConversationParticipant,
        lastMessageText: String?,
        lastMessageDate: Date?,
        unreadCount: Int
    ) {
        self.id = id
        self.participant = participant
        self.lastMessageText = lastMessageText
        self.lastMessageDate = lastMessageDate
        self.unreadCount = unreadCount
    }
}
