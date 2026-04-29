//
//  ChatViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Networking
import Observation
import Common

@MainActor
@Observable
final class ChatViewModel {
    let conversationId: String
    let participantName: String
    private(set) var messages: [MessageViewData] = []
    private(set) var isLoadingOlder = false
    private(set) var hasOlderMessages = true
    private(set) var isSending = false
    private(set) var anchorMessageId: String?
    var inputText: String = ""

    /// User ID (not Rider ID) of the other conversation participant. Resolved from the
    /// repository cache populated by the conversations list / open-or-create flows.
    var participantUserId: UUID? {
        repository.conversations
            .first { $0.id == conversationId }
            .flatMap { UUID(uuidString: $0.otherUser.id) }
    }

    private let repository: ChatRepository
    private let currentUserId: String
    private let dateFormatting = DateFormatting.shared

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
        repository.setCurrentConversation(conversationId)
        startObservingRepository()

        guard messages.isEmpty else {
            // Already loaded once — still (re)issue a mark-as-read in case a
            // message arrived while we were backgrounded.
            Task { await repository.markAsRead(conversationId: conversationId) }
            return
        }

        Task {
            await repository.loadMessages(for: conversationId, refresh: true)
            hasOlderMessages = repository.hasMoreMessages[conversationId] ?? true
            syncMessages()

            // Scenario A: mark as read immediately after messages load.
            await repository.markAsRead(conversationId: conversationId)
        }
    }

    /// Called when the chat view disappears. Clears the "current conversation"
    /// pointer so incoming messages start incrementing the unread badge again.
    func onDisappear() {
        if repository.currentConversationId == conversationId {
            repository.setCurrentConversation(nil)
        }
    }

    // MARK: - Repository Observation

    /// Starts observing repository changes (socket events, background refreshes).
    /// Re-registers automatically until the ViewModel is deallocated.
    private func startObservingRepository() {
        observeRepository()
    }

    private func observeRepository() {
        withObservationTracking {
            _ = repository.messages(for: conversationId)
            _ = repository.otherUserLastReadAt[conversationId]
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.syncMessages()
                self.observeRepository()
            }
        }
    }

    // MARK: - Older messages (infinite scroll up)

    func loadOlderMessages() {
        guard !isLoadingOlder, hasOlderMessages else { return }
        anchorMessageId = messages.first?.id
        isLoadingOlder = true

        Task {
            await repository.loadOlderMessages(for: conversationId)
            hasOlderMessages = repository.hasMoreMessages[conversationId] ?? true
            syncMessages()
            isLoadingOlder = false
        }
    }

    /// Clears the anchor after the view handled scroll preservation.
    func consumeAnchor() {
        anchorMessageId = nil
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
        let lastReadAt = repository.otherUserLastReadAt[conversationId]
        messages = raw.map { mapMessage($0, otherUserLastReadAt: lastReadAt) }
    }

    // MARK: - Private

    private func mapMessage(
        _ message: ChatMessage,
        otherUserLastReadAt: String?
    ) -> MessageViewData {
        let date = dateFormatting.parseISO8601(message.createdAt)
        let isFromCurrentUser = message.senderId == currentUserId

        let isRead: Bool = {
            guard isFromCurrentUser, let lastReadAt = otherUserLastReadAt else { return false }
            // Both timestamps are ISO-8601 — lexicographic comparison is safe
            // as long as both use the same format (UTC with same fractional precision).
            return message.createdAt <= lastReadAt
        }()

        return MessageViewData(
            id: message.id,
            text: message.content,
            timeText: date.map { dateFormatting.formatTime($0) } ?? "",
            isFromCurrentUser: isFromCurrentUser,
            isRead: isRead
        )
    }
}
