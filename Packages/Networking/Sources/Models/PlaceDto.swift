//
//  PlaceDto.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import Foundation

public struct PlaceDto: Decodable, Equatable, Sendable {
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
    public let emoji: PlaceTagEmojiDto?
    public let createdAt: Date
}

/// Placeholder for the backend emoji object in TagEntity.
public struct PlaceTagEmojiDto: Decodable, Equatable, Sendable {}

public struct GeoPointDto: Decodable, Equatable, Sendable {
    public let lat: Double
    public let lng: Double
}
