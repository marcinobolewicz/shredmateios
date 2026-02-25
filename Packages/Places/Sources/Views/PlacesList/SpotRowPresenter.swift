//
//  SpotRowPresenter.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation

struct SpotRowPresenter: Sendable {
    func map(place: Place) -> SpotRowViewData {
        let sportTags = place.sports.map { $0.name }
        let sportIds = place.sports.map { $0.id }
        return SpotRowViewData(
            id: place.id,
            title: place.name,
            description: place.description,
            sportTags: sportTags,
            sportIds: sportIds,
            ridersCount: place.ridersCount,
            mentorsCount: place.mentorsCount,
            avatar: place.avatarURL != nil ? .imageRemote(place.avatarURL) : .initials(initials(from: place.name))
        )
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
