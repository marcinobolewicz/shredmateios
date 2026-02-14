//
//  ConversationsMockData.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import Foundation

enum ConversationsMockData {
    static let currentUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    static let participants: [ConversationParticipant] = [
        ConversationParticipant(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            displayName: "Kasia Nowak",
            avatarURL: nil
        ),
        ConversationParticipant(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
            displayName: "Tomek Wiśniewski",
            avatarURL: nil
        ),
        ConversationParticipant(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
            displayName: "Ola Kowalska",
            avatarURL: nil
        ),
    ]

    static let conversations: [Conversation] = [
        Conversation(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!,
            participant: participants[0],
            lastMessageText: "Hej, jedziesz jutro na stok?",
            lastMessageDate: date(2026, 2, 14, 10, 30),
            unreadCount: 2
        ),
        Conversation(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!,
            participant: participants[1],
            lastMessageText: "Dzięki za sesję mentorską!",
            lastMessageDate: date(2026, 2, 13, 18, 15),
            unreadCount: 0
        ),
        Conversation(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!,
            participant: participants[2],
            lastMessageText: "Super warunki dzisiaj 🏂",
            lastMessageDate: date(2026, 2, 12, 9, 0),
            unreadCount: 0
        ),
    ]

    static func messages(for conversationId: UUID) -> [Message] {
        let participantId = conversations
            .first { $0.id == conversationId }?.participant.id ?? participants[0].id

        return [
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Elo", sentAt: date(2026, 2, 14, 9, 2)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Elo zyjesz", sentAt: date(2026, 2, 13, 9, 4)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Elo mordo", sentAt: date(2026, 2, 13, 9, 5)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "daj znać jak będziesz", sentAt: date(2026, 2, 13, 9, 6)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "albo i nie", sentAt: date(2026, 2, 13, 9, 7)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", sentAt: date(2026, 2, 14, 9, 0)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Elo", sentAt: date(2026, 2, 14, 7, 0)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Halo", sentAt: date(2026, 2, 14, 8, 0)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Yellow", sentAt: date(2026, 2, 14, 9, 0)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Jedziesz dzisiaj?", sentAt: date(2026, 2, 14, 9, 1)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: currentUserId, text: "Jasne, o której?", sentAt: date(2026, 2, 14, 9, 5)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Myślę o 10:00", sentAt: date(2026, 2, 14, 9, 6)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: currentUserId, text: "Spoko, będę!", sentAt: date(2026, 2, 14, 9, 10)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: participantId, text: "Super, to do zobaczenia na górze 🏔️",
                    sentAt: date(2026, 2, 14, 9, 12)),
            Message(id: UUID(), conversationId: conversationId,
                    senderId: currentUserId, text: "Lecę! 🏂", sentAt: date(2026, 2, 14, 9, 15)),
        ]
    }

    static let searchableRiders: [RiderSearchRowViewData] = [
        RiderSearchRowViewData(id: UUID(), displayName: "Kasia Nowak", avatarInitials: "KN", avatarURL: nil),
        RiderSearchRowViewData(id: UUID(), displayName: "Tomek Wiśniewski", avatarInitials: "TW", avatarURL: nil),
        RiderSearchRowViewData(id: UUID(), displayName: "Ola Kowalska", avatarInitials: "OK", avatarURL: nil),
        RiderSearchRowViewData(id: UUID(), displayName: "Marek Zieliński", avatarInitials: "MZ", avatarURL: nil),
        RiderSearchRowViewData(id: UUID(), displayName: "Anna Wójcik", avatarInitials: "AW", avatarURL: nil),
    ]

    // MARK: - Helpers

    private static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? .now
    }
}
