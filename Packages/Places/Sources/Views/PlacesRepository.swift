//
//  PlacesRepository.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Networking

protocol PlacesRepositoryProtocol: Sendable {
    func fetchPlaces(for sportSlug: String) async throws -> [Place]
}

final class PlacesRepository: PlacesRepositoryProtocol, Sendable {
    let service: any PlacesServiceProtocol

    init(service: any PlacesServiceProtocol) {
        self.service = service
    }

    func fetchPlaces(for sportSlug: String) async throws -> [Place] {
        let dtos = try await service.fetchPlaces(sportSlug: sportSlug)
        return dtos.map(PlaceMapper.map)
    }
}

