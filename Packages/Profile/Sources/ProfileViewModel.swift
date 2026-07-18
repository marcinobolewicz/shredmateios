import Foundation
import Observation
import Networking

/// Profile editing state
@MainActor
@Observable
public final class ProfileViewModel {
    
    // MARK: - State
    
    public private(set) var rider: Rider?
    public private(set) var baseLocation: RiderBaseLocation?
    public private(set) var allSports: [Sport] = []
    public private(set) var riderSports: [RiderSport] = []
    
    public private(set) var isLoading = false
    public private(set) var isSaving = false
    public private(set) var isUploadingAvatar = false
    public private(set) var error: String?
    public private(set) var successMessage: String?
    
    /// Per-sport loading state (for inline spinners)
    public private(set) var sportLoadingIds: Set<String> = []
    
    // MARK: - Editable Fields
    
    public var displayName: String = ""
    public var description: String = ""
    public var isPublic: Bool = true
    public var avatarImage: Data?
    
    // Base location fields
    public var locationName: String = ""
    public var latitudeText: String = ""
    public var longitudeText: String = ""
    
    // MARK: - Dependencies

    private let repository: any ProfileRepositoryProtocol
    private let presenter: ProfileFormPresenter
    private let authState: AuthState
    let feedService: any FeedServiceProtocol
    let mentorSlotsService: any MentorSlotsServiceProtocol
    let placesService: any PlacesServiceProtocol
    let stripeOnboardingViewModel: StripeOnboardingViewModel

    // MARK: - Computed

    public var riderId: UUID? { rider?.id }

    public var isMentor: Bool {
        guard let type = rider?.type else { return false }
        return type == .mentor || type == .both
    }

    public var hasMentorSports: Bool {
        riderSports.contains(where: \.isMentor)
    }

    // MARK: - Init

    public init(
        riderService: any RiderServiceProtocol,
        sportsService: any SportsServiceProtocol,
        placesService: any PlacesServiceProtocol,
        feedService: any FeedServiceProtocol,
        mentorSlotsService: any MentorSlotsServiceProtocol,
        stripeService: any StripeServiceProtocol,
        authState: AuthState,
        legalService: (any LegalServiceProtocol)? = nil
    ) {
        self.repository = ProfileRepository(riderService: riderService, sportsService: sportsService)
        self.presenter = ProfileFormPresenter()
        self.feedService = feedService
        self.mentorSlotsService = mentorSlotsService
        self.placesService = placesService
        self.stripeOnboardingViewModel = StripeOnboardingViewModel(
            stripeService: stripeService,
            legalService: legalService
        )
        self.authState = authState
    }

    init(
        repository: any ProfileRepositoryProtocol,
        placesService: any PlacesServiceProtocol,
        feedService: any FeedServiceProtocol,
        mentorSlotsService: any MentorSlotsServiceProtocol,
        stripeOnboardingViewModel: StripeOnboardingViewModel,
        presenter: ProfileFormPresenter = .init(),
        authState: AuthState
    ) {
        self.repository = repository
        self.presenter = presenter
        self.feedService = feedService
        self.mentorSlotsService = mentorSlotsService
        self.placesService = placesService
        self.stripeOnboardingViewModel = stripeOnboardingViewModel
        self.authState = authState
    }
    
    // MARK: - Load Data
    
    /// Load all profile data
    public func loadProfile() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let snapshot = try await repository.fetchProfileSnapshot()
            rider = snapshot.rider
            baseLocation = snapshot.baseLocation
            allSports = snapshot.sports
            riderSports = snapshot.riderSports

            let profileForm = presenter.mapProfileForm(from: snapshot.rider)
            displayName = profileForm.displayName
            description = profileForm.description
            isPublic = profileForm.isPublic

            let locationForm = presenter.mapLocationForm(from: snapshot.baseLocation)
            latitudeText = locationForm.latitudeText
            longitudeText = locationForm.longitudeText

            if hasMentorSports {
                await stripeOnboardingViewModel.loadStatus()
            }
        } catch {
            self.error = ProfileStrings.failedLoadProfile(error.localizedDescription)
        }
    }

    // MARK: - Update Profile

    /// Save profile changes (displayName, description, type)
    public func saveProfile() async {
        guard validateProfileFields() else { return }

        isSaving = true
        error = nil
        successMessage = nil

        defer { isSaving = false }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let request = UpdateRiderRequest(
            type: nil,
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarUrl: nil,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            isPublic: isPublic
        )

        do {
            let updatedRider = try await repository.updateProfile(request)
            rider = updatedRider
        } catch {
            self.error = ProfileStrings.failedUpdateProfile(error.localizedDescription)
            return
        }

        if let imageData = avatarImage {
            do {
                let response = try await repository.uploadAvatar(imageData)
                rider = presenter.riderAfterAvatarUpload(current: rider, avatarURL: response.avatarUrl)
                avatarImage = nil
            } catch {
                self.error = ProfileStrings.failedUploadAvatar(error.localizedDescription)
                return
            }
        }

        successMessage = ProfileStrings.profileUpdatedSuccess.localized
    }
    
    /// Upload avatar image
    public func uploadAvatar() async {
        guard let imageData = avatarImage else {
            error = ProfileStrings.noImageSelected.localized
            return
        }
        
        isUploadingAvatar = true
        error = nil
        
        defer { isUploadingAvatar = false }
        
        do {
            let response = try await repository.uploadAvatar(imageData)
            rider = presenter.riderAfterAvatarUpload(current: rider, avatarURL: response.avatarUrl)
            
            successMessage = ProfileStrings.avatarUploadedSuccess.localized
            avatarImage = nil
            
            await authState.fetchRiderProfile()
        } catch {
            self.error = ProfileStrings.failedUploadAvatar(error.localizedDescription)
        }
    }
    
    // MARK: - Base Location
    
    /// Save base location
    public func saveBaseLocation() async {
        guard validateLocationFields() else { return }
        
        guard let lat = Double(latitudeText),
              let lng = Double(longitudeText) else {
                        error = ProfileStrings.invalidCoordinates.localized
            return
        }
        
        isSaving = true
        error = nil
        
        defer { isSaving = false }
        
        let request = UpdateBaseLocationRequest(
            latitude: lat,
            longitude: lng
        )
        
        do {
            let updated = try await repository.updateBaseLocation(request)
            baseLocation = updated
            successMessage = ProfileStrings.locationSavedSuccess.localized
        } catch {
            self.error = ProfileStrings.failedSaveLocation(error.localizedDescription)
        }
    }
    
    // MARK: - Sports Management
    
    /// Add or update a sport
    public func upsertSport(sportId: String, level: SkillLevel, isMentor: Bool) async {
        sportLoadingIds.insert(sportId)
        error = nil
        
        defer { sportLoadingIds.remove(sportId) }
        
        let request = UpsertRiderSportRequest(level: level, isMentor: isMentor)
        
        do {
            let updatedSport = try await repository.upsertSport(sportId: sportId, request: request)
            
            if let index = riderSports.firstIndex(where: { $0.sportId.caseInsensitiveCompare(sportId) == .orderedSame }) {
                riderSports[index] = updatedSport
            } else {
                riderSports.append(updatedSport)
            }
        } catch {
            self.error = ProfileStrings.failedUpdateSport(error.localizedDescription)
        }
    }
    
    /// Remove a sport
    public func removeSport(sportId: String) async {
        sportLoadingIds.insert(sportId)
        error = nil
        
        defer { sportLoadingIds.remove(sportId) }
        
        do {
            try await repository.removeSport(sportId: sportId)
            riderSports.removeAll { $0.sportId.caseInsensitiveCompare(sportId) == .orderedSame }
        } catch {
            self.error = ProfileStrings.failedRemoveSport(error.localizedDescription)
        }
    }
    
    /// Check if a sport is currently loading
    public func isSportLoading(_ sportId: String) -> Bool {
        sportLoadingIds.contains(where: { $0.caseInsensitiveCompare(sportId) == .orderedSame })
    }
    
    /// Get rider's sport by sportId
    public func riderSport(for sportId: String) -> RiderSport? {
        riderSports.first { $0.sportId.caseInsensitiveCompare(sportId) == .orderedSame }
    }
    
    // MARK: - Delete Account
    
    /// Log out current session
    public func logout() async {
        await authState.logout()
    }

    /// Delete user account
    public func deleteAccount() async {
        isLoading = true
        error = nil
        
        do {
            try await repository.deleteAccount()
            await authState.handleSessionInvalidation()
        } catch {
            // 409 = active bookings / unsettled payments block deletion (server guard).
            if case NetworkError.requestFailed(let statusCode) = error, statusCode == 409 {
                self.error = ProfileStrings.deleteAccountBlocked.localized
            } else {
                self.error = ProfileStrings.failedDeleteAccount(error.localizedDescription)
            }
            isLoading = false
        }
    }

    // MARK: - Helpers
    
    private func validateProfileFields() -> Bool {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            error = ProfileStrings.displayNameRequired.localized
            return false
        }
        
        if trimmed.count > 40 {
            error = ProfileStrings.displayNameMaxLength(40)
            return false
        }
        
        if description.count > 1000 {
            error = ProfileStrings.descriptionMaxLength(1000)
            return false
        }
        
        return true
    }
    
    private func validateLocationFields() -> Bool {
        guard let lat = Double(latitudeText),
              let lng = Double(longitudeText) else {
            error = ProfileStrings.enterValidCoordinates.localized
            return false
        }
        
        if lat < -90 || lat > 90 {
            error = ProfileStrings.latitudeRangeError.localized
            return false
        }
        
        if lng < -180 || lng > 180 {
            error = ProfileStrings.longitudeRangeError.localized
            return false
        }
        
        return true
    }
    
    public func clearMessages() {
        error = nil
        successMessage = nil
    }
}
