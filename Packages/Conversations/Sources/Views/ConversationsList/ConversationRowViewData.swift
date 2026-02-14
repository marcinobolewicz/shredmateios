//
//  ConversationRowViewData.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

struct ConversationRowViewData: Identifiable, Equatable, Sendable {
    let id: UUID
    let participantName: String
    let lastMessage: String
    let dateText: String
    let avatarInitials: String
    let avatarURL: URL?
    let unreadCount: Int
}
