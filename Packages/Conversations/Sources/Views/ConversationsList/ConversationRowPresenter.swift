//
//  ConversationRowPresenter.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

struct ConversationRowPresenter: Sendable {
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d.MM.yyyy"
        return f
    }()

    func map(conversation: Conversation) -> ConversationRowViewData {
        ConversationRowViewData(
            id: conversation.id,
            participantName: conversation.participant.displayName,
            lastMessage: conversation.lastMessageText ?? "",
            dateText: conversation.lastMessageDate.map { dateFormatter.string(from: $0) } ?? "",
            avatarInitials: initials(from: conversation.participant.displayName),
            avatarURL: conversation.participant.avatarURL,
            unreadCount: conversation.unreadCount
        )
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
