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
    private(set) var isLoadingRiders = false
    private(set) var error: String?
    private(set) var riderEntries: [PlaceRiderPresence] = []
    private(set) var selectedSportSlug: String?

    var showRolePicker = false

    let placeId: UUID
    let sportIds: [UUID]
    let sportFilters: [PlaceDetailsViewData.SportFilter]

    // MARK: - Dependencies

    private let placesService: any PlacesServiceProtocol
    private let authState: AuthState
    private let rowPresenter: PlaceRiderRowPresenter
    private let sportPreferenceStorage: any SportPreferenceStorageProtocol
    private var lastLoadedSportSlug: String?

    // MARK: - Init

    init(
        placeId: UUID,
        sportIds: [UUID],
        sportFilters: [PlaceDetailsViewData.SportFilter],
        placesService: any PlacesServiceProtocol,
        authState: AuthState,
        sportPreferenceStorage: any SportPreferenceStorageProtocol,
        rowPresenter: PlaceRiderRowPresenter = .init()
    ) {
        self.placeId = placeId
        self.sportIds = sportIds
        self.sportFilters = sportFilters
        self.placesService = placesService
        self.authState = authState
        self.sportPreferenceStorage = sportPreferenceStorage
        self.rowPresenter = rowPresenter
        self.selectedSportSlug = nil
    }

    var ridersRows: [PlaceRiderRowViewData] {
        riderEntries
            .filter { $0.role != .mentor }
            .map(rowPresenter.map)
    }

    var mentorsRows: [PlaceRiderRowViewData] {
        riderEntries
            .filter { $0.role == .mentor }
            .map(rowPresenter.map)
    }

    var ridersCount: Int { ridersRows.count }

    var mentorsCount: Int { mentorsRows.count }

    func selectSport(_ sportSlug: String) async {
        guard selectedSportSlug != sportSlug else { return }
        selectedSportSlug = sportSlug
        Task { await sportPreferenceStorage.saveSportSlug(sportSlug) }
        await loadRiders(force: true)
    }

    func applySavedSportPreference() async {
        guard selectedSportSlug == nil,
              let savedSlug = await sportPreferenceStorage.savedSportSlug(),
              sportFilters.contains(where: { $0.slug == savedSlug }) else { return }
        selectedSportSlug = savedSlug
    }

    func loadRiders(force: Bool = false) async {
        guard !isLoadingRiders else { return }
        if !force, !riderEntries.isEmpty, lastLoadedSportSlug == selectedSportSlug { return }

        isLoadingRiders = true
        error = nil
        defer { isLoadingRiders = false }

        do {
            riderEntries = try await placesService.fetchPlaceRiders(
                placeId: placeId,
                sportSlug: selectedSportSlug,
                sportId: nil
            )
            lastLoadedSportSlug = selectedSportSlug
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Membership

    private(set) var isCheckingMembership = false
    private(set) var membershipSportId: UUID?

    func checkMembership() async {
        guard authState.isLoggedIn else { return }
        isCheckingMembership = true
        defer { isCheckingMembership = false }

        do {
            let membership = try await placesService.myMembership(placeId: placeId)
            hasJoined = true
            joinedRole = membership.role
            membershipSportId = membership.sportId
        } catch {
            hasJoined = false
            joinedRole = nil
            membershipSportId = nil
        }
    }

    // MARK: - Join Place

    func joinWith(role: PlaceRiderRole) async {
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
            membershipSportId = response.sportId ?? someSportId
            await loadRiders(force: true)
        } catch {
            self.error = PlacesStrings.failedCheckIn(error.localizedDescription)
        }
    }

    // MARK: - Leave Place

    private(set) var isLeaving = false

    func leavePlace() async {
        guard let sportId = membershipSportId ?? sportIds.first else { return }
        isLeaving = true
        error = nil
        defer { isLeaving = false }

        do {
            try await placesService.leavePlace(placeId: placeId, sportId: sportId)
            hasJoined = false
            joinedRole = nil
            membershipSportId = nil
            await loadRiders(force: true)
        } catch {
            self.error = PlacesStrings.failedCheckOut(error.localizedDescription)
        }
    }

    func clearError() {
        error = nil
    }
}
