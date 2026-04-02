//
//  PlaceDto.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import Foundation

public struct PlaceDto: Decodable, Equatable, Sendable, Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let avatarUrl: URL?
    public let location: GeoPointDto?
    public let createdByUserId: UUID?
    public let createdAt: Date
    public let updatedAt: Date
    public let sports: [PlaceSportDto]?
    public let tags: [PlaceTagDto]?
    public let mentorsCount: Int?
    public let ridersCount: Int?

    public init(
        id: UUID,
        name: String,
        description: String? = nil,
        avatarUrl: URL? = nil,
        location: GeoPointDto? = nil,
        createdByUserId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sports: [PlaceSportDto]? = nil,
        tags: [PlaceTagDto]? = nil,
        mentorsCount: Int? = nil,
        ridersCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.avatarUrl = avatarUrl
        self.location = location
        self.createdByUserId = createdByUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sports = sports
        self.tags = tags
        self.mentorsCount = mentorsCount
        self.ridersCount = ridersCount
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct PlaceSportDto: Decodable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let slug: String
}

public struct PlaceTagDto: Decodable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let slug: String
    public let emoji: String?
}

public struct GeoPointDto: Decodable, Equatable, Sendable {
    public let lat: Double
    public let lng: Double
}
