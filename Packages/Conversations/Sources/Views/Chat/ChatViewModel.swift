//
//  ChatViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Networking

@MainActor
@Observable
final class ChatViewModel {
    let conversationId: String
    let participantName: String
    private(set) var messages: [MessageViewData] = []
    private(set) var isLoadingOlder = false
    private(set) var hasOlderMessages = true
    private(set) var isSending = false
    var inputText: String = ""

    private let repository: ChatRepository
    private let currentUserId: String

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    init(
        conversationId: String,
        participantName: String,
        repository: ChatRepository,
        currentUserId: String
    ) {
        self.conversationId = conversationId
        self.participantName = participantName
        self.repository = repository
        self.currentUserId = currentUserId
    }

    // MARK: - Loading

    func loadOnAppear() {
        guard messages.isEmpty else { return }

        Task {
            await repository.loadMessages(for: conversationId, refresh: true)
            syncMessages()
        }
    }

    // MARK: - Older messages (infinite scroll up)

    func loadOlderMessages() {
        guard !isLoadingOlder, hasOlderMessages else { return }
        isLoadingOlder = true

        Task {
            await repository.loadOlderMessages(for: conversationId)
            hasOlderMessages = repository.hasMoreMessages[conversationId] ?? true
            syncMessages()
            isLoadingOlder = false
        }
    }

    // MARK: - Send

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        isSending = true
        inputText = ""

        Task {
            do {
                _ = try await repository.sendMessage(conversationId: conversationId, text: text)
                syncMessages()
            } catch {
                // Restore input on failure so user can retry
                inputText = text
            }
            isSending = false
        }
    }

    // MARK: - Sync

    /// Re-maps messages from the repository cache. Call after socket events.
    func syncMessages() {
        let raw = repository.messages(for: conversationId)
        messages = raw.map { mapMessage($0) }
    }

    // MARK: - Private

    private func mapMessage(_ message: ChatMessage) -> MessageViewData {
        let date = isoFormatter.date(from: message.createdAt)

        return MessageViewData(
            id: message.id,
            text: message.content,
            timeText: date.map { timeFormatter.string(from: $0) } ?? "",
            isFromCurrentUser: message.senderId == currentUserId
        )
    }
}
