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
    private let placesService: PlacesServiceProtocol
    private let sportsService: SportsServiceProtocol
    private let riderService: RiderServiceProtocol
    private let mentorSlotsService: MentorSlotsServiceProtocol
    private let sportPreferenceStorage: any SportPreferenceStorageProtocol
    private let onOpenChat: (_ userId: UUID, _ displayName: String) -> Void
    private let onRequestLogin: (() -> Void)?
    @State private var router = PlacesRouter()

    public init(
        placesService: PlacesServiceProtocol,
        sportsService: SportsServiceProtocol,
        riderService: RiderServiceProtocol,
        mentorSlotsService: MentorSlotsServiceProtocol,
        sportPreferenceStorage: any SportPreferenceStorageProtocol,
        onOpenChat: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in },
        onRequestLogin: (() -> Void)? = nil
    ) {
        self.placesService = placesService
        self.sportsService = sportsService
        self.riderService = riderService
        self.mentorSlotsService = mentorSlotsService
        self.sportPreferenceStorage = sportPreferenceStorage
        self.onOpenChat = onOpenChat
        self.onRequestLogin = onRequestLogin
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            PlacesView(
                placesService: placesService,
                sportsService: sportsService,
                sportPreferenceStorage: sportPreferenceStorage
            )
            .navigationBarHidden(true)
            .placesDestinations(
                placesService: placesService,
                riderService: riderService,
                mentorSlotsService: mentorSlotsService,
                sportPreferenceStorage: sportPreferenceStorage,
                onOpenChat: onOpenChat,
                onRequestLogin: onRequestLogin
            )
        }
        .environment(router)
    }
}

