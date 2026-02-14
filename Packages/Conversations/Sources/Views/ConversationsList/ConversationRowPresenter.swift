//
//  ConversationRowPresenter.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation
import Networking

struct ConversationRowPresenter: Sendable {

    // MARK: - Map from API model

    func map(conversation: ChatConversation) -> ConversationRowViewData {
        let name = conversation.otherUser.name ?? conversation.otherUser.email ?? "Unknown"
        let date = conversation.lastMessageAt.flatMap { Formatters.iso8601.date(from: $0) }

        return ConversationRowViewData(
            id: conversation.id,
            participantName: name,
            lastMessage: conversation.lastMessage?.content ?? "",
            dateText: date.map { Formatters.displayDate.string(from: $0) } ?? "",
            avatarInitials: initials(from: name),
            avatarURL: conversation.otherUser.avatarUrl.flatMap { URL(string: $0) },
            unreadCount: 0 // API does not provide unread count yet
        )
    }

    // MARK: - Map from local model (backward compat)

    func map(conversation: Conversation) -> ConversationRowViewData {
        ConversationRowViewData(
            id: conversation.id.uuidString,
            participantName: conversation.participant.displayName,
            lastMessage: conversation.lastMessageText ?? "",
            dateText: conversation.lastMessageDate.map { Formatters.displayDate.string(from: $0) } ?? "",
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

// MARK: - Formatters

private enum Formatters {
    nonisolated(unsafe) static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    nonisolated(unsafe) static let displayDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d.MM.yyyy"
        return f
    }()
}
