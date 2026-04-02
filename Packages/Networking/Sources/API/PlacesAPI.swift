//
//  PlacesAPI.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import Foundation

public enum PlacesAPI {

    public static func places(sportSlug: String?) -> Endpoint<[PlaceDto]> {
        .get(
            "/places",
            query: [URLQueryItem(name: "sportSlug", value: sportSlug)]
        )
    }

    public static func placeRiders(
        placeId: UUID,
        sportSlug: String? = nil,
        sportId: UUID? = nil
    ) -> Endpoint<[PlaceRiderPresence]> {
        var query: [URLQueryItem] = []
        if let sportSlug {
            query.append(URLQueryItem(name: "sportSlug", value: sportSlug))
        }
        if let sportId {
            query.append(URLQueryItem(name: "sportId", value: sportId.uuidString.lowercased()))
        }
        return .get("/places/\(placeId.uuidString.lowercased())/riders", query: query, auth: .bearerToken)
    }

    // MARK: - Join / Leave Place

    public static func joinPlace(
        placeId: UUID,
        request: JoinPlaceRequest
    ) -> Endpoint<PlaceJoinResponse> {
        .post("/places/\(placeId.uuidString.lowercased())/join", body: request, keys: .camelCase, auth: .bearerToken)
    }

    public static func leavePlace(
        placeId: UUID,
        sportId: UUID
    ) -> Endpoint<EmptyResponse> {
        .delete(
            "/places/\(placeId.uuidString.lowercased())/join",
            query: [URLQueryItem(name: "sportId", value: sportId.uuidString.lowercased())],
            auth: .bearerToken
        )
    }

    public static func myMembership(placeId: UUID) -> Endpoint<[PlaceMembership]> {
        .get("/places/\(placeId.uuidString.lowercased())/my-membership", auth: .bearerToken)
    }
}
