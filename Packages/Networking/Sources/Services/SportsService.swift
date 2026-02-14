//
//  SportsService.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 01/02/2026.
//

import Foundation

public protocol SportsServiceProtocol: Sendable {
    func fetchSports() async throws -> [Sport]
}

public final class SportsServiceService: SportsServiceProtocol, Sendable {
    
    private let client: APIClienting
    
    public init(client: APIClienting) {
        self.client = client
    }
    
    public func fetchSports() async throws -> [Sport] {
        try await client.send(SportsAPI.all())
    }
}
