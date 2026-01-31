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
}
