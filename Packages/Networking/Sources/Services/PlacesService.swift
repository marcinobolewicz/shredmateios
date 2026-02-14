//
//  PlacesService.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import Foundation

public protocol PlacesServiceProtocol: Sendable {
    func fetchPlaces(sportSlug: String) async throws -> [PlaceDto]
}

public final class PlacesService: PlacesServiceProtocol, Sendable {
    
    private let client: APIClienting
    
    public init(client: APIClienting) {
        self.client = client
    }
    
    public func fetchPlaces(sportSlug: String) async throws -> [PlaceDto] {
        try await client.send(PlacesAPI.places(sportSlug: sportSlug))
    }
}
