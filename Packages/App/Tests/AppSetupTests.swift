import XCTest
@testable import App

final class AppSetupTests: XCTestCase {
    @MainActor
    func testAppSetup() async {
        await AppSetup.configure()
        // If we get here without crashing, setup succeeded
        XCTAssertTrue(true)
    }
}
