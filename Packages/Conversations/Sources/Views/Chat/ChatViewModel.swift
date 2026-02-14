//
//  ChatViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI

@MainActor
@Observable
final class ChatViewModel {
    let conversationId: UUID
    let participantName: String
    private(set) var messages: [MessageViewData] = []
    var inputText: String = ""

    private let currentUserId = ConversationsMockData.currentUserId
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    init(conversationId: UUID, participantName: String) {
        self.conversationId = conversationId
        self.participantName = participantName
    }

    func loadOnAppear() {
        guard messages.isEmpty else { return }
        let raw = ConversationsMockData.messages(for: conversationId)
        messages = raw.map { mapMessage($0) }
    }

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let message = Message(
            id: UUID(),
            conversationId: conversationId,
            senderId: currentUserId,
            text: text,
            sentAt: .now
        )

        messages.append(mapMessage(message))
        inputText = ""

        // TODO: Send via socket / service
    }

    private func mapMessage(_ message: Message) -> MessageViewData {
        MessageViewData(
            id: message.id,
            text: message.text,
            timeText: timeFormatter.string(from: message.sentAt),
            isFromCurrentUser: message.senderId == currentUserId
        )
    }
}
