//import Foundation
//import Core
//
///// Networking service that uses the Core's network client
//public actor NetworkingService: Sendable {
//    private let client: any NetworkClient
//    
//    public init(client: any NetworkClient) {
//        self.client = client
//    }
//    
//    /// Fetch data from an endpoint
//    public func fetch<T: Decodable & Sendable>(from endpoint: String) async throws -> T {
//        return try await client.request(endpoint)
//    }
//}
