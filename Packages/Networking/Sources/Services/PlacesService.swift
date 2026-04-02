//
//  PlacesService.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import Foundation

public protocol PlacesServiceProtocol: Sendable {
    func fetchPlaces(sportSlug: String?) async throws -> [PlaceDto]
    func fetchPlaceRiders(placeId: UUID, sportSlug: String?, sportId: UUID?) async throws -> [PlaceRiderPresence]
    func joinPlace(placeId: UUID, sportId: UUID, role: PlaceRiderRole, rating: Int?) async throws -> PlaceJoinResponse
    func leavePlace(placeId: UUID, sportId: UUID) async throws
    func myMembership(placeId: UUID) async throws -> PlaceMembership?
}

public final class PlacesService: PlacesServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func fetchPlaces(sportSlug: String?) async throws -> [PlaceDto] {
        try await client.send(PlacesAPI.places(sportSlug: sportSlug))
    }

    public func fetchPlaceRiders(placeId: UUID, sportSlug: String? = nil, sportId: UUID? = nil) async throws -> [PlaceRiderPresence] {
        try await client.send(PlacesAPI.placeRiders(placeId: placeId, sportSlug: sportSlug, sportId: sportId))
    }

    public func joinPlace(placeId: UUID, sportId: UUID, role: PlaceRiderRole, rating: Int? = nil) async throws -> PlaceJoinResponse {
        let request = JoinPlaceRequest(sportId: sportId, role: role, rating: rating)
        return try await client.send(PlacesAPI.joinPlace(placeId: placeId, request: request))
    }

    public func leavePlace(placeId: UUID, sportId: UUID) async throws {
        _ = try await client.send(PlacesAPI.leavePlace(placeId: placeId, sportId: sportId))
    }

    public func myMembership(placeId: UUID) async throws -> PlaceMembership? {
        try await client.send(PlacesAPI.myMembership(placeId: placeId)).first
    }
}
