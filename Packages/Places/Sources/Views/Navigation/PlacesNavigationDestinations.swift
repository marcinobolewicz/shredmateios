//
//  PlacesNavigationDestinations.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Networking

public struct PlacesNavigationDestinations: ViewModifier {
    let placesService: PlacesServiceProtocol
    @Environment(AuthState.self) private var authState

    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: PlacesRoute.self) { route in
                destination(for: route)
            }
    }

    @ViewBuilder
    private func destination(for route: PlacesRoute) -> some View {
        switch route {
        case .placeDetails(let viewData):
            PlaceDetailsView(
                viewData: viewData,
                placesService: placesService,
                authState: authState
            )
        }
    }
}

public extension View {
    func placesDestinations(placesService: PlacesServiceProtocol) -> some View {
        modifier(PlacesNavigationDestinations(placesService: placesService))
    }
}
