//
//  NewConversationViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Networking
import Common

@MainActor
@Observable
final class NewConversationViewModel {
    var searchText: String = ""
    private(set) var riders: [RiderSearchRowViewData] = []
    private(set) var state: LoadState = .idle
    private(set) var isCreating = false
    private(set) var createdConversation: ChatConversation?
    private(set) var error: Error?

    private let repository: ChatRepository
    private let riderService: any RiderServiceProtocol
    private var allRiders: [RiderSearchRowViewData] = []

    init(repository: ChatRepository, riderService: any RiderServiceProtocol) {
        self.repository = repository
        self.riderService = riderService
    }

    func load() {
        guard case .idle = state else { return }
        state = .loading

        Task {
            do {
                let fetched = try await riderService.fetchAllRiders()
                allRiders = fetched.map { mapRider($0) }
                applyFilter()
                state = .loaded
            } catch {
                state = .failed(.from(error))
            }
        }
    }

    func onSearchChanged() {
        applyFilter()
    }

    func retry() {
        state = .idle
        load()
    }

    /// Opens or creates a conversation with the given rider.
    /// On success, sets `createdConversation` for the caller to navigate.
    func startConversation(with rider: RiderSearchRowViewData) async {
        guard !isCreating else { return }
        isCreating = true
        error = nil

        do {
            let conversation = try await repository.openOrCreateConversation(
                otherUserId: rider.id
            )
            createdConversation = conversation
        } catch {
            self.error = error
        }

        isCreating = false
    }

    // MARK: - Private

    private func applyFilter() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            riders = allRiders
        } else {
            riders = allRiders.filter {
                $0.displayName.localizedCaseInsensitiveContains(query)
            }
        }
    }

    private func mapRider(_ rider: Rider) -> RiderSearchRowViewData {
        let name = rider.displayName ?? "Rider"
        return RiderSearchRowViewData(
            id: rider.userId,
            displayName: name,
            avatarInitials: initials(from: name),
            avatarURL: rider.avatarUrl.flatMap { URL(string: $0) }
        )
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
