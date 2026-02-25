//
//  PlacesRepository.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Networking

protocol PlacesRepositoryProtocol: Sendable {
    func fetchPlaces(for sportSlug: String?) async throws -> [Place]
    func fetchSports() async throws -> [PlaceSport]
}

final class PlacesRepository: PlacesRepositoryProtocol, Sendable {
    let service: any PlacesServiceProtocol
    let sportsService: any SportsServiceProtocol

    init(service: any PlacesServiceProtocol, sportsService: any SportsServiceProtocol) {
        self.service = service
        self.sportsService = sportsService
    }
    
    func fetchSports() async throws -> [PlaceSport] {
        let dtos = try await sportsService.fetchSports()
        return dtos.map(SportMapper.map)
    }
    
    func fetchPlaces(for sportSlug: String?) async throws -> [Place] {
        let dtos = try await service.fetchPlaces(sportSlug: sportSlug)
        return dtos.map(PlaceMapper.map)
    }
}

