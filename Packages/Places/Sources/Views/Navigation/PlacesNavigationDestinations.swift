//
//  PlacesNavigationDestinations.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Networking
import Payment
import Foundation

public struct PlacesNavigationDestinations: ViewModifier {
    let placesService: PlacesServiceProtocol
    let riderService: RiderServiceProtocol
    let mentorSlotsService: MentorSlotsServiceProtocol
    let sportPreferenceStorage: any SportPreferenceStorageProtocol
    let onOpenChat: (_ userId: UUID, _ displayName: String) -> Void
    let onRequestLogin: (() -> Void)?
    @Environment(AuthState.self) private var authState
    @Environment(FollowRepository.self) private var followRepository
    @Environment(StripePaymentService.self) private var stripePaymentService

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
                riderService: riderService,
                authState: authState,
                sportPreferenceStorage: sportPreferenceStorage,
                onRequestLogin: onRequestLogin
            )
        case .riderCard(let viewData):
            RiderDetailLoadingView(
                partialViewData: viewData,
                riderService: riderService,
                mentorSlotsService: mentorSlotsService,
                stripePaymentService: stripePaymentService,
                onMessageTap: onOpenChat
            )
        }
    }
}

public extension View {
    func placesDestinations(
        placesService: PlacesServiceProtocol,
        riderService: RiderServiceProtocol,
        mentorSlotsService: MentorSlotsServiceProtocol,
        sportPreferenceStorage: any SportPreferenceStorageProtocol,
        onOpenChat: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in },
        onRequestLogin: (() -> Void)? = nil
    ) -> some View {
        modifier(
            PlacesNavigationDestinations(
                placesService: placesService,
                riderService: riderService,
                mentorSlotsService: mentorSlotsService,
                sportPreferenceStorage: sportPreferenceStorage,
                onOpenChat: onOpenChat,
                onRequestLogin: onRequestLogin
            )
        )
    }
}
