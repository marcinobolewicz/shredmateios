//
//  Place.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation

public struct Place: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let avatarURL: URL?
    public let location: GeoPoint?
    public let sports: [PlaceSport]
    public let tags: [PlaceTag]
    public let ridersCount: Int
    public let mentorsCount: Int
}

public struct PlaceSport: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let slug: String
}

public struct PlaceTag: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let slug: String
    public let emoji: String?
}

///// Placeholder for the backend emoji object in TagEntity.
//public struct PlaceTagEmoji: Equatable, Sendable {}

public struct GeoPoint: Equatable, Sendable {
    public let lat: Double
    public let lng: Double
}
