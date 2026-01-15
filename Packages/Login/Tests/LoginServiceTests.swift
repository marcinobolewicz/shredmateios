import XCTest
@testable import Login
import Networking
import Core

final class LoginServiceTests: XCTestCase {
    func testLoginServiceStub() async throws {
        let client = URLSessionClient(baseURL: "https://api.test.com")
        let networkingService = NetworkingService(client: client)
        let loginService = LoginService(networkingService: networkingService)
        
        let response = try await loginService.login(username: "test", password: "test")
        
        XCTAssertEqual(response.token, "stub-token")
        XCTAssertEqual(response.userId, "stub-user-id")
    }
}
