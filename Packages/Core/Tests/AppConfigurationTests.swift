import XCTest
@testable import Core

final class AppConfigurationTests: XCTestCase {
    func testAppConfigurationInitialization() async {
        let config = AppConfiguration.shared
        
        let baseURL = await config.getAPIBaseURL()
        XCTAssertFalse(baseURL.isEmpty)
        
        let environment = await config.getEnvironment()
        XCTAssertFalse(environment.isEmpty)
    }
}
