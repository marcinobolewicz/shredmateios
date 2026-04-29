//
//  PlaceDetailsViewModel.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 25/02/2026.
//

import Foundation
import CoreLocation
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
    var showLocationUpdatePrompt = false
    var showLocationMapPicker = false

    let placeId: UUID
    let sportIds: [UUID]
    let sportFilters: [PlaceDetailsViewData.SportFilter]
    let placeLocation: CLLocationCoordinate2D?

    // MARK: - Dependencies

    private let placesService: any PlacesServiceProtocol
    private let riderService: any RiderServiceProtocol
    private let authState: AuthState
    private let rowPresenter: PlaceRiderRowPresenter
    private let sportPreferenceStorage: any SportPreferenceStorageProtocol
    private let locationPromptPolicy: LocationPromptPolicy
    private var lastLoadedSportSlug: String?

    // MARK: - Init

    init(
        placeId: UUID,
        sportIds: [UUID],
        sportFilters: [PlaceDetailsViewData.SportFilter],
        placeLocation: CLLocationCoordinate2D?,
        placesService: any PlacesServiceProtocol,
        riderService: any RiderServiceProtocol,
        authState: AuthState,
        sportPreferenceStorage: any SportPreferenceStorageProtocol,
        locationPromptPolicy: LocationPromptPolicy = .default,
        rowPresenter: PlaceRiderRowPresenter = .init()
    ) {
        self.placeId = placeId
        self.sportIds = sportIds
        self.sportFilters = sportFilters
        self.placeLocation = placeLocation
        self.placesService = placesService
        self.riderService = riderService
        self.authState = authState
        self.sportPreferenceStorage = sportPreferenceStorage
        self.locationPromptPolicy = locationPromptPolicy
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

    var isGuest: Bool { !authState.isLoggedIn }

    func loadRiders(force: Bool = false) async {
        guard authState.isLoggedIn else { return }
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
            if let membership = try await placesService.myMembership(placeId: placeId) {
                hasJoined = true
                joinedRole = membership.role
                membershipSportId = membership.sportId
            } else {
                hasJoined = false
                joinedRole = nil
                membershipSportId = nil
            }
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
            await evaluateLocationPrompt()
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

    // MARK: - Location Prompt

    private func evaluateLocationPrompt() async {
        guard let spot = placeLocation else { return }
        let current = try? await riderService.fetchMyBaseLocation()
        guard locationPromptPolicy.shouldPrompt(current: current, spot: spot) else { return }
        showLocationUpdatePrompt = true
    }

    func confirmAutoLocationUpdate() async {
        guard let spot = placeLocation else { return }
        let offset = locationPromptPolicy.autoUpdateCoordinate(for: spot)
        await updateBaseLocation(to: offset)
    }

    func confirmMapLocation(_ coordinate: CLLocationCoordinate2D) async {
        await updateBaseLocation(to: coordinate)
    }

    private func updateBaseLocation(to coordinate: CLLocationCoordinate2D) async {
        do {
            _ = try await riderService.updateMyBaseLocation(
                UpdateBaseLocationRequest(latitude: coordinate.latitude, longitude: coordinate.longitude)
            )
        } catch {
            self.error = PlacesStrings.failedUpdateBaseLocation(error.localizedDescription)
        }
    }
}
