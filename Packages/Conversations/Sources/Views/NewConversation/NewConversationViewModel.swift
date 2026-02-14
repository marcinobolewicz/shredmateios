//
//  NewConversationViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI

@MainActor
@Observable
final class NewConversationViewModel {
    var searchText: String = ""
    private(set) var riders: [RiderSearchRowViewData] = []

    private let allRiders = ConversationsMockData.searchableRiders

    func load() {
        applyFilter()
    }

    func onSearchChanged() {
        applyFilter()
    }

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
}
