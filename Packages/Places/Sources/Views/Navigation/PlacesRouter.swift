//
//  PlacesRouter.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI

@Observable
public final class PlacesRouter {
    public var path = NavigationPath()

    public init() {}

    public func navigate(to route: PlacesRoute) {
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
