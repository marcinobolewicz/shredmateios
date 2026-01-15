import Foundation

/// Protocol for RiderService abstraction (enables testing)
public protocol RiderServiceProtocol: Sendable {
    func fetchMyRider() async throws -> Rider
    func updateMyRider(_ update: UpdateRiderRequest) async throws -> Rider
    func deleteMyAccount() async throws
}

/// Service handling rider profile operations
public actor RiderService: RiderServiceProtocol {
    
    private let httpClient: AuthHTTPClient
    
    public init(httpClient: AuthHTTPClient) {
        self.httpClient = httpClient
    }
    
    public func fetchMyRider() async throws -> Rider {
        try await httpClient.get("/riders/me")
    }
    
    public func updateMyRider(_ update: UpdateRiderRequest) async throws -> Rider {
        try await httpClient.patch("/riders/me", body: update)
    }
    
    public func deleteMyAccount() async throws {
        try await httpClient.delete("/riders/me")
    }
}
