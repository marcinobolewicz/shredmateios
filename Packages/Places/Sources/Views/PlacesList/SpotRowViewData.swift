//
//  SpotRowViewData.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation
import Common

struct SpotRowViewData: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let latitude: Double?
    let longitude: Double?
    let sportTags: [String]
    let placeTags: [String]
    let sportIds: [UUID]
    let sportSlugs: [String]
    let ridersCount: Int
    let mentorsCount: Int
    let avatar: Avatar

    var initials: String {
        if case .initials(let text) = avatar { return text }
        let parts = title.split(separator: " ")
        let letters = parts.prefix(2).compactMap(\.first)
        return String(letters).uppercased()
    }

    var placeDetailsData: PlaceDetailsViewData {
        PlaceDetailsViewData(
            id: id,
            name: title,
            description: description,
            sportTags: sportTags,
            placeTags: placeTags,
            sportIds: sportIds,
            sportSlugs: sportSlugs,
            ridersCount: ridersCount,
            mentorsCount: mentorsCount,
            avatar: avatar,
            latitude: latitude,
            longitude: longitude
        )
    }
}
