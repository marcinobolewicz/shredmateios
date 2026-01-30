//
//  PlacesAPI.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import Foundation

public enum PlacesAPI {
    
    public static func places(sportSlug: String) -> Endpoint<[PlaceDto]> {
        .get(
            "/places",
            query: [URLQueryItem(name: "sportSlug", value: sportSlug)],
            auth: .bearerToken
        )
    }
}
