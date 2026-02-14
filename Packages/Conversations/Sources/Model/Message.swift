//
//  Message.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

public struct Message: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let conversationId: UUID
    public let senderId: UUID
    public let text: String
    public let sentAt: Date

    public init(
        id: UUID,
        conversationId: UUID,
        senderId: UUID,
        text: String,
        sentAt: Date
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.text = text
        self.sentAt = sentAt
    }
}
