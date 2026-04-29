//
//  ConversationRowPresenter.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
import Networking
import Common

struct ConversationRowPresenter: Sendable {

    // MARK: - Map from API model

    func map(conversation: ChatConversation) -> ConversationRowViewData {
        let name = conversation.otherUser.name ?? conversation.otherUser.email ?? "Unknown"
        let date = conversation.lastMessageAt.flatMap { DateFormatting.shared.parseISO8601($0) }

        return ConversationRowViewData(
            id: conversation.id,
            participantName: name,
            lastMessage: conversation.lastMessage?.content ?? "",
            dateText: date.map { DateFormatting.shared.formatDisplayDate($0) } ?? "",
            avatarInitials: initials(from: name),
            avatarURL: conversation.otherUser.avatarUrl.flatMap { URL(string: $0) },
            unreadCount: conversation.unreadCount
        )
    }

    // MARK: - Map from local model (backward compat)

    func map(conversation: Conversation) -> ConversationRowViewData {
        ConversationRowViewData(
            id: conversation.id.uuidString,
            participantName: conversation.participant.displayName,
            lastMessage: conversation.lastMessageText ?? "",
            dateText: conversation.lastMessageDate.map { DateFormatting.shared.formatDisplayDate($0) } ?? "",
            avatarInitials: initials(from: conversation.participant.displayName),
            avatarURL: conversation.participant.avatarURL,
            unreadCount: conversation.unreadCount
        )
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
