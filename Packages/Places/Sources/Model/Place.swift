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
}

public struct GeoPoint: Equatable, Sendable {
    public let lat: Double
    public let lng: Double
}
