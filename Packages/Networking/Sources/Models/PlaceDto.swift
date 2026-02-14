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
}


public struct GeoPointDto: Decodable, Equatable, Sendable {
    public let lat: Double
    public let lng: Double
}
