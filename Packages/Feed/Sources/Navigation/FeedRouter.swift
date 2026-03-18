import SwiftUI

@Observable
public final class FeedRouter {
    public var path = NavigationPath()

    public init() {}

    public func navigate(to route: FeedRoute) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }
}
