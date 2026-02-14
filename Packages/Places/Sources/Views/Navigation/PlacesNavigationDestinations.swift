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

    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: PlacesRoute.self) { route in
                destination(for: route)
            }
    }

    @ViewBuilder
    private func destination(for route: PlacesRoute) -> some View {
        switch route {
        case .placeDetails(let id):
            PlaceDetailsView(
//                placesService: dependencies.placesService,
//                authState: dependencies.authState
            )
        }

    }
}

public extension View {
    func placesDestinations(placesService: PlacesServiceProtocol) -> some View {
        modifier(PlacesNavigationDestinations(placesService: placesService))
    }
}
