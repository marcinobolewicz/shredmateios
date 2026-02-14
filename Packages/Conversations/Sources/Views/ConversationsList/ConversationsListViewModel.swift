//
//  ConversationsListViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Common

@MainActor
@Observable
final class ConversationsListViewModel {
    private(set) var rows: [ConversationRowViewData] = []
    private(set) var state: LoadState = .idle
    var searchText: String = ""

    private let presenter = ConversationRowPresenter()

    func loadOnAppear() {
        guard case .idle = state else { return }
        load()
    }

    func refresh() {
        load()
    }

    func load() {
        state = .loading

        // TODO: Replace with real service call
        let conversations = ConversationsMockData.conversations
        let mapped = conversations.map { presenter.map(conversation: $0) }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            rows = mapped
        } else {
            rows = mapped.filter {
                $0.participantName.localizedCaseInsensitiveContains(query)
            }
        }

        state = .loaded
    }
}
