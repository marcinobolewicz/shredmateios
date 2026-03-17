//
//  PlacesNavigationDestinations.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Networking
import Foundation

public struct PlacesNavigationDestinations: ViewModifier {
    let placesService: PlacesServiceProtocol
    let onOpenChat: (_ userId: UUID, _ displayName: String) -> Void
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
        case .riderCard(let viewData):
            RiderCardView(
                viewData: viewData,
                onMessageTap: onOpenChat
            )
        }
    }
}

public extension View {
    func placesDestinations(
        placesService: PlacesServiceProtocol,
        onOpenChat: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) -> some View {
        modifier(
            PlacesNavigationDestinations(
                placesService: placesService,
                onOpenChat: onOpenChat
            )
        )
    }
}
