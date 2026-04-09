import Foundation
import Observation
import SwiftUI

/// Protocol for auth navigation (enables testing with mocks).
@MainActor
public protocol AuthRouting: AnyObject {
    var current: AuthRoute { get set }
    func navigate(to route: AuthRoute)
    func reset()
}

/// State-driven router for the authentication flow.
///
/// The auth flow is intentionally shallow — login, register, forgot
/// password — so a state machine is a better fit than a navigation stack:
/// no back button to manage, no transition coupling, and the close button
/// can sit on a single container above the switched content.
@MainActor
@Observable
public final class AuthRouter: AuthRouting {

    public var current: AuthRoute

    public init(initial: AuthRoute = .login) {
        self.current = initial
    }

    public func navigate(to route: AuthRoute) {
        current = route
    }

    /// Returns the flow to its root entry (login).
    public func reset() {
        current = .login
    }
}
