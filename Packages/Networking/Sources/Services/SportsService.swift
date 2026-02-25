//
//  SportsService.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation

public protocol SportsServiceProtocol: Sendable {
    func fetchSports() async throws -> [Sport]
    func refreshSports() async throws -> [Sport]
}

public final actor SportsServiceService: SportsServiceProtocol {
    private let client: APIClienting
    private var cachedSports: [Sport]?
    
    public init(client: APIClienting) {
        self.client = client
    }
    
    public func fetchSports() async throws -> [Sport] {
        if let cachedSports {
            return cachedSports
        }
        
        let sports: [Sport] = try await client.send(SportsAPI.all())
        self.cachedSports = sports
        return sports
    }
    
    public func refreshSports() async throws -> [Sport] {
        let sports: [Sport] = try await client.send(SportsAPI.all())
        self.cachedSports = sports
        return sports
    }
}
