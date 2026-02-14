//
//  ConversationsListViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Common
import Networking

@MainActor
@Observable
final class ConversationsListViewModel {
    private(set) var rows: [ConversationRowViewData] = []
    private(set) var state: LoadState = .idle
    var searchText: String = ""

    private let repository: ChatRepository
    private let presenter = ConversationRowPresenter()

    init(repository: ChatRepository) {
        self.repository = repository
    }

    // MARK: - Loading

    func loadOnAppear() {
        guard case .idle = state else { return }
        load()
    }

    func refresh() {
        load()
    }

    func load() {
        state = .loading

        Task {
            await repository.loadConversations(refresh: true)
            mapRows()

            if let error = repository.conversationsError {
                state = .failed(.from(error))
            } else {
                state = .loaded
            }
        }
    }

    // MARK: - Infinite Scroll

    func loadNextPage() {
        guard !repository.isLoadingConversations, repository.hasMoreConversations else { return }

        Task {
            await repository.loadNextConversationsPage()
            mapRows()
        }
    }

    /// Called when a row appears — triggers next page load for the last item (sentinel).
    func onRowAppear(_ row: ConversationRowViewData) {
        if row.id == rows.last?.id {
            loadNextPage()
        }
    }

    // MARK: - Sync from repository

    /// Re-maps rows from the repository. Call after socket events or mutations.
    func syncFromRepository() {
        mapRows()
    }

    // MARK: - Private

    private func mapRows() {
        let mapped = repository.conversations.map { presenter.map(conversation: $0) }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            rows = mapped
        } else {
            rows = mapped.filter {
                $0.participantName.localizedCaseInsensitiveContains(query)
            }
        }
    }
}
