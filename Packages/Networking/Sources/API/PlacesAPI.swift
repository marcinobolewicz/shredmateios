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
    ) -> Endpoint<[Rider]> {
        var query: [URLQueryItem] = []
        if let sportSlug {
            query.append(URLQueryItem(name: "sportSlug", value: sportSlug))
        }
        if let sportId {
            query.append(URLQueryItem(name: "sportId", value: sportId.uuidString))
        }
        return .get("/places/\(placeId.uuidString)/riders", query: query)
    }

    // MARK: - Join Place

    public static func joinPlace(
        placeId: UUID,
        request: JoinPlaceRequest
    ) -> Endpoint<PlaceJoinResponse> {
        .post("/places/\(placeId.uuidString)/join", body: request, auth: .bearerToken)
    }
}
