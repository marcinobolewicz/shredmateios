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
            subtitle: "—", // TODO: from BE
            description: place.description,
            sportTag: sport.rawValue,
            ratingText: "★ 4.2",      // TODO: from BE
            ridersText: "Riders 18",  // TODO: from BE
            mentorsText: "Mentorzy 4",
            avatar: place.avatarURL != nil ? .imageRemote(place.avatarURL) : .initials(initials(from: place.name))
        )
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
