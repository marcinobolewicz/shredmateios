//
//  ConversationsRoute.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

public enum ConversationsRoute: Hashable {
    case chat(conversationId: String, participantName: String)
    case riderProfile(userId: UUID, displayName: String)
}
