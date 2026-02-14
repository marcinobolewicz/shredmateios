//
//  SpotRowViewData.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation

struct SpotRowViewData: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let description: String
    let sportTag: String
    let rating: Double
    let ridersCount: Int
    let mentorsCount: Int
    let avatar: Avatar
}

enum Avatar: Equatable {
    case image(String)
    case imageRemote(URL?)
    case initials(String)
}
