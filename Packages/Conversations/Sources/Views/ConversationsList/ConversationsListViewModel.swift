//
//  ConversationsListViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Common
import Networking
import Observation

@MainActor
@Observable
final class ConversationsListViewModel {
    private(set) var rows: [ConversationRowViewData] = []
    private(set) var state: LoadState = .idle
    var searchText: String = ""

    private let repository: ChatRepository
    private let presenter = ConversationRowPresenter()
    private var isObserving = false

    init(repository: ChatRepository) {
        self.repository = repository
    }

    // MARK: - Loading

    func loadOnAppear() {
        startObservingRepository()
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

    // MARK: - Repository Observation

    /// Starts observing repository changes (socket events, background refreshes).
    /// Re-registers automatically until the ViewModel is deallocated.
    private func startObservingRepository() {
        guard !isObserving else { return }
        isObserving = true
        observeRepository()
    }

    private func observeRepository() {
        withObservationTracking {
            _ = repository.conversations
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.syncFromRepository()
                self.observeRepository()
            }
        }
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
