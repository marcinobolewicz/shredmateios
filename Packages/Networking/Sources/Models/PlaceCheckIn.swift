//
//  PlaceCheckIn.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 25/02/2026.
//

import Foundation

/// Role a rider takes when checking in to a place
public enum PlaceRiderRole: String, Codable, Sendable, CaseIterable, Identifiable {
    case rider = "RIDER"
    case mentor = "MENTOR"

    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .rider: return "Rider"
        case .mentor: return "Mentor"
        }
    }
}

/// Request body for joining a place (POST /places/{id}/join)
public struct JoinPlaceRequest: Encodable, Sendable {
    public let sportId: UUID
    public let role: PlaceRiderRole
    public let rating: Int?
    
    public init(sportId: UUID, role: PlaceRiderRole, rating: Int? = nil) {
        self.sportId = sportId
        self.role = role
        self.rating = rating
    }
}

/// Response model for joining a place
public struct PlaceJoinResponse: Decodable, Sendable, Equatable {
    public let id: String?
    public let riderId: String?
    public let placeId: UUID?
    public let sportId: UUID?
    public let role: PlaceRiderRole?
    public let rating: Int?
    public let createdAt: Date?
}
