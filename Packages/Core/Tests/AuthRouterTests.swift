import XCTest
@testable import Core

@MainActor
final class AuthRouterTests: XCTestCase {

    private var router: AuthRouter!

    override func setUp() async throws {
        router = AuthRouter()
    }

    func testInitialRouteIsLogin() {
        XCTAssertEqual(router.current, .login)
    }

    func testInitialRouteCanBeOverridden() {
        let preset = AuthRouter(initial: .register)

        XCTAssertEqual(preset.current, .register)
    }

    func testNavigateUpdatesCurrent() {
        router.navigate(to: .register)

        XCTAssertEqual(router.current, .register)
    }

    func testNavigateOverwritesPrevious() {
        router.navigate(to: .register)
        router.navigate(to: .forgotPassword)

        XCTAssertEqual(router.current, .forgotPassword)
    }

    func testResetReturnsToLogin() {
        router.navigate(to: .forgotPassword)

        router.reset()

        XCTAssertEqual(router.current, .login)
    }
}
