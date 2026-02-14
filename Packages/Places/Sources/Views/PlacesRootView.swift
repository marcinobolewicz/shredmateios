//
//  PlacesRootView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Networking

public struct PlacesRootView: View {
    @Environment(AuthState.self) private var authState
    private let placesService: PlacesServiceProtocol
    
    @State private var router = PlacesRouter()

    public init(
        placesService: PlacesServiceProtocol,
    ) {
        self.placesService = placesService
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            PlacesView(
                placesService: placesService,
                authState: authState
            )
            .navigationTitle("Spots")
            .placesDestinations(
                placesService: placesService
            )
        }
        .environment(router)
    }
}

