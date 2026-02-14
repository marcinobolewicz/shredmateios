//
//  SpotRowPresenter.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation

struct SpotRowPresenter: Sendable {
    func map(place: Place, sport: Sport) -> SpotRowViewData {
        SpotRowViewData(
            id: place.id,
            title: place.name,
            subtitle: PlacesStrings.spotSubtitlePlaceholder.localized,
            description: place.description,
            sportTag: sport.localizedTitle,
            rating: 4.2,
            ridersCount: 18,
            mentorsCount: 4,
            avatar: place.avatarURL != nil ? .imageRemote(place.avatarURL) : .initials(initials(from: place.name))
        )
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
