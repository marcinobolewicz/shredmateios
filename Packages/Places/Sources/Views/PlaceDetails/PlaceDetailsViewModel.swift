//
//  PlaceDetailsViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 25/02/2026.
//

import Foundation
import Networking
import Common

@MainActor
@Observable
final class PlaceDetailsViewModel {

    // MARK: - State

    private(set) var hasJoined = false
    private(set) var joinedRole: PlaceRiderRole?
    private(set) var isJoining = false
    private(set) var error: String?

    var showRolePicker = false

    let placeId: UUID
    let sportId: UUID?

    // MARK: - Dependencies

    private let placesService: any PlacesServiceProtocol
    private let authState: AuthState

    // MARK: - Init

    init(
        placeId: UUID,
        sportId: UUID?,
        placesService: any PlacesServiceProtocol,
        authState: AuthState
    ) {
        self.placeId = placeId
        self.sportId = sportId
        self.placesService = placesService
        self.authState = authState
    }

    // MARK: - Join Place

    func joinWith(role: PlaceRiderRole) async {
        guard let sportId else {
            error = PlacesStrings.failedCheckIn("No sport available")
            return
        }

        isJoining = true
        error = nil
        defer { isJoining = false }

        do {
            let response = try await placesService.joinPlace(
                placeId: placeId,
                sportId: sportId,
                role: role,
                rating: nil
            )
            hasJoined = true
            joinedRole = response.role ?? role
        } catch {
            self.error = PlacesStrings.failedCheckIn(error.localizedDescription)
        }
    }

    func clearError() {
        error = nil
    }
}

