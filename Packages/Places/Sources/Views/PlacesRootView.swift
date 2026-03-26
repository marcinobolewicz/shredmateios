//
//  PlacesRootView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Networking
import Foundation
import Theme

public struct PlacesRootView: View {
    @Environment(AuthState.self) private var authState
    private let placesService: PlacesServiceProtocol
    private let sportsService: SportsServiceProtocol
    private let riderService: RiderServiceProtocol
    private let mentorSlotsService: MentorSlotsServiceProtocol
    private let sportPreferenceStorage: any SportPreferenceStorageProtocol
    private let onOpenChat: (_ userId: UUID, _ displayName: String) -> Void
    @State private var router = PlacesRouter()

    public init(
        placesService: PlacesServiceProtocol,
        sportsService: SportsServiceProtocol,
        riderService: RiderServiceProtocol,
        mentorSlotsService: MentorSlotsServiceProtocol,
        sportPreferenceStorage: any SportPreferenceStorageProtocol,
        onOpenChat: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.placesService = placesService
        self.sportsService = sportsService
        self.riderService = riderService
        self.mentorSlotsService = mentorSlotsService
        self.sportPreferenceStorage = sportPreferenceStorage
        self.onOpenChat = onOpenChat
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            PlacesView(
                placesService: placesService,
                sportsService: sportsService,
                authState: authState,
                sportPreferenceStorage: sportPreferenceStorage
            )
            .navigationBarHidden(true)
            .placesDestinations(
                placesService: placesService,
                riderService: riderService,
                mentorSlotsService: mentorSlotsService,
                sportPreferenceStorage: sportPreferenceStorage,
                onOpenChat: onOpenChat
            )
        }
        .environment(router)
    }
}

