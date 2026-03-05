//
//  PlacesRootView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Networking
import Foundation

public struct PlacesRootView: View {
    @Environment(AuthState.self) private var authState
    private let placesService: PlacesServiceProtocol
    private let sportsService: SportsServiceProtocol
    private let onOpenChat: (_ userId: UUID, _ displayName: String) -> Void
    @State private var router = PlacesRouter()

    public init(
        placesService: PlacesServiceProtocol,
        sportsService: SportsServiceProtocol,
        onOpenChat: @escaping (_ userId: UUID, _ displayName: String) -> Void = { _, _ in }
    ) {
        self.placesService = placesService
        self.sportsService = sportsService
        self.onOpenChat = onOpenChat
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            PlacesView(
                placesService: placesService,
                sportsService: sportsService,
                authState: authState
            )
            .navigationTitle(PlacesStrings.rootNavigationTitle.localized)
            .placesDestinations(
                placesService: placesService,
                onOpenChat: onOpenChat
            )
        }
        .environment(router)
    }
}

