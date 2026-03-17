import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    func testEndpointCreation() async {
        let endpoint = Endpoint<EmptyResponse>.get("/test", auth: .bearerToken)
        
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.path, "/test")
        XCTAssertEqual(endpoint.auth, .bearerToken)
    }
    
    func testAPIClientInitialization() async {
        let baseURL = URL(string: "https://api.test.com")!
        let client = APIClient(baseURL: baseURL)
        
        XCTAssertNotNil(client)
    }

    func testUpdateBaseLocationRequestUsesBaseLocationPayload() throws {
        let endpoint = RiderAPI.updateBaseLocation(
            UpdateBaseLocationRequest(latitude: 52.2297, longitude: 21.0122)
        )
        let request = try DefaultRequestBuilder().makeRequest(
            baseURL: URL(string: "https://api.test.com")!,
            endpoint: endpoint
        )

        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )
        let baseLocation = try XCTUnwrap(json["baseLocation"] as? [String: Any])

        XCTAssertEqual(request.httpMethod, HTTPMethod.put.rawValue)
        XCTAssertEqual(baseLocation["lat"] as? Double, 52.2297)
        XCTAssertEqual(baseLocation["lng"] as? Double, 21.0122)
        XCTAssertNil(json["lat"])
        XCTAssertNil(json["lng"])
    }
}
