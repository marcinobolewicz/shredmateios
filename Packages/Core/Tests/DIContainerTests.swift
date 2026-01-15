import XCTest
@testable import Core

final class DIContainerTests: XCTestCase {
    @MainActor
    func testDIContainerRegistrationAndResolution() async {
        let container = DIContainer.shared
        
        // Register a test dependency
        container.register(String.self) {
            return "test-value"
        }
        
        // Resolve the dependency
        let resolved = container.resolve(String.self)
        
        XCTAssertEqual(resolved, "test-value")
    }
}
