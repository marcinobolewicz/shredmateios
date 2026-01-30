//
//  RiderService.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 29/01/2026.
//

import Foundation

/// Protocol for RiderService abstraction (enables testing)
public protocol RiderServiceProtocol: Sendable {
    // Profile
    func fetchMyRider() async throws -> Rider
    func updateMyRider(_ update: UpdateRiderRequest) async throws -> Rider
    func uploadAvatar(_ imageData: Data) async throws -> AvatarUploadResponse
    func deleteMyAccount() async throws
    
    // Base Location
    func fetchMyBaseLocation() async throws -> RiderBaseLocation?
    func updateMyBaseLocation(_ location: UpdateBaseLocationRequest) async throws -> RiderBaseLocation
    
    // Sports
    func fetchAllSports() async throws -> [Sport]
    func fetchMyRiderSports() async throws -> [RiderSport]
    func upsertMyRiderSport(sportId: String, request: UpsertRiderSportRequest) async throws -> RiderSport
    func deleteMyRiderSport(sportId: String) async throws
}

/// Service handling rider profile operations
public final class RiderService: RiderServiceProtocol, Sendable {
    
    private let client: APIClienting
    
    public init(client: APIClienting) {
        self.client = client
    }
    
    // MARK: - Profile
    
    public func fetchMyRider() async throws -> Rider {
        try await client.send(RiderAPI.me())
    }
    
    public func updateMyRider(_ update: UpdateRiderRequest) async throws -> Rider {
        try await client.send(RiderAPI.updateMe(update))
    }
    
    public func uploadAvatar(_ imageData: Data) async throws -> AvatarUploadResponse {
        try await client.send(RiderAPI.uploadAvatar(imageData: imageData))
    }
    
    public func deleteMyAccount() async throws {
        _ = try await client.send(RiderAPI.deleteMe())
    }
    
    // MARK: - Base Location
    
    public func fetchMyBaseLocation() async throws -> RiderBaseLocation? {
        do {
            return try await client.send(RiderAPI.baseLocation())
        } catch let error as NetworkError {
            // 404 means no base location set
            if case .requestFailed(let code) = error, code == 404 {
                return nil
            }
            throw error
        }
    }
    
    public func updateMyBaseLocation(_ location: UpdateBaseLocationRequest) async throws -> RiderBaseLocation {
        try await client.send(RiderAPI.updateBaseLocation(location))
    }
    
    // MARK: - Sports
    
    public func fetchAllSports() async throws -> [Sport] {
        try await client.send(SportsAPI.all())
    }
    
    public func fetchMyRiderSports() async throws -> [RiderSport] {
        try await client.send(RiderAPI.sports())
    }
    
    public func upsertMyRiderSport(sportId: String, request: UpsertRiderSportRequest) async throws -> RiderSport {
        try await client.send(RiderAPI.upsertSport(sportId: sportId, request: request))
    }
    
    public func deleteMyRiderSport(sportId: String) async throws {
        _ = try await client.send(RiderAPI.deleteSport(sportId: sportId))
    }
}
