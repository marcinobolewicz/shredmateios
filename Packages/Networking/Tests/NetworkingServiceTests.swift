import XCTest
@testable import Networking
import Core

final class NetworkingServiceTests: XCTestCase {
    func testNetworkingServiceInitialization() async {
        let client = URLSessionClient(baseURL: "https://api.test.com")
        let service = NetworkingService(client: client)
        
        XCTAssertNotNil(service)
    }
}
