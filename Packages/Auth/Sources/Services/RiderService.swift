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
public actor RiderService: RiderServiceProtocol {
    
    private let httpClient: AuthHTTPClient
    
    public init(httpClient: AuthHTTPClient) {
        self.httpClient = httpClient
    }
    
    // MARK: - Profile
    
    public func fetchMyRider() async throws -> Rider {
        try await httpClient.get("/riders/me")
    }
    
    public func updateMyRider(_ update: UpdateRiderRequest) async throws -> Rider {
        try await httpClient.patch("/riders/me", body: update)
    }
    
    public func uploadAvatar(_ imageData: Data) async throws -> AvatarUploadResponse {
        try await httpClient.uploadMultipart(
            "/riders/me/avatar",
            fileData: imageData,
            fileName: "avatar.jpg",
            mimeType: "image/jpeg"
        )
    }
    
    public func deleteMyAccount() async throws {
        try await httpClient.delete("/riders/me")
    }
    
    // MARK: - Base Location
    
    public func fetchMyBaseLocation() async throws -> RiderBaseLocation? {
        do {
            return try await httpClient.get("/riders/me/base-location")
        } catch let error as AuthError {
            // 404 or 204 means no base location set
            if case .serverError(let code) = error, code == 404 {
                return nil
            }
            throw error
        }
    }
    
    public func updateMyBaseLocation(_ location: UpdateBaseLocationRequest) async throws -> RiderBaseLocation {
        try await httpClient.put("/riders/me/base-location", body: location)
    }
    
    // MARK: - Sports
    
    public func fetchAllSports() async throws -> [Sport] {
        try await httpClient.get("/sports")
    }
    
    public func fetchMyRiderSports() async throws -> [RiderSport] {
        try await httpClient.get("/riders/me/sports")
    }
    
    public func upsertMyRiderSport(sportId: String, request: UpsertRiderSportRequest) async throws -> RiderSport {
        try await httpClient.post("/riders/me/sports/\(sportId)", body: request)
    }
    
    public func deleteMyRiderSport(sportId: String) async throws {
        try await httpClient.delete("/riders/me/sports/\(sportId)")
    }
}
