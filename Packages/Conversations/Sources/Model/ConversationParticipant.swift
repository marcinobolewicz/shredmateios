//
//  ConversationParticipant.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

public struct ConversationParticipant: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let displayName: String
    public let avatarURL: URL?

    public init(id: UUID, displayName: String, avatarURL: URL?) {
        self.id = id
        self.displayName = displayName
        self.avatarURL = avatarURL
    }
}
