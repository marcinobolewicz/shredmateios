import XCTest
@testable import Core

@MainActor
final class AuthRouterTests: XCTestCase {
    
    private var router: AuthRouter!
    
    override func setUp() async throws {
        router = AuthRouter()
    }
    
    func testInitialPathIsEmpty() {
        XCTAssertTrue(router.path.isEmpty)
    }
    
    func testNavigateAppendsRoute() {
        router.navigate(to: .register)
        
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first, .register)
    }
    
    func testNavigateMultipleRoutes() {
        router.navigate(to: .register)
        router.navigate(to: .forgotPassword)
        
        XCTAssertEqual(router.path.count, 2)
        XCTAssertEqual(router.path, [.register, .forgotPassword])
    }
    
    func testPopRemovesLastRoute() {
        router.navigate(to: .register)
        router.navigate(to: .forgotPassword)
        
        router.pop()
        
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first, .register)
    }
    
    func testPopOnEmptyPathDoesNothing() {
        router.pop()
        
        XCTAssertTrue(router.path.isEmpty)
    }
    
    func testPopToRootClearsPath() {
        router.navigate(to: .register)
        router.navigate(to: .forgotPassword)
        
        router.popToRoot()
        
        XCTAssertTrue(router.path.isEmpty)
    }
}
