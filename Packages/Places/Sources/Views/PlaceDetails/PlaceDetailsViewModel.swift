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
    let sportIds: [UUID]

    // MARK: - Dependencies

    private let placesService: any PlacesServiceProtocol
    private let authState: AuthState

    // MARK: - Init

    init(
        placeId: UUID,
        sportIds: [UUID],
        placesService: any PlacesServiceProtocol,
        authState: AuthState
    ) {
        self.placeId = placeId
        self.sportIds = sportIds
        self.placesService = placesService
        self.authState = authState
    }

    // MARK: - Join Place

    func joinWith(role: PlaceRiderRole) async {
        // TODO: check if user sports match spot types
        guard let someSportId = sportIds.first else { return }
        isJoining = true
        error = nil
        defer { isJoining = false }

        do {
            let response = try await placesService.joinPlace(
                placeId: placeId,
                sportId: someSportId,
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
