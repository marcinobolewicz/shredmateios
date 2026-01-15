import Foundation
import Observation
import SwiftUI

/// Protocol for auth navigation (enables testing with mocks)
@MainActor
public protocol AuthRouting: AnyObject {
    var path: [AuthRoute] { get set }
    func navigate(to route: AuthRoute)
    func pop()
    func popToRoot()
}

/// Router for authentication flow using NavigationStack
@MainActor
@Observable
public final class AuthRouter: AuthRouting {
    
    public var path: [AuthRoute] = []
    
    public init() {}
    
    public func navigate(to route: AuthRoute) {
        path.append(route)
    }
    
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    public func popToRoot() {
        path.removeAll()
    }
}
