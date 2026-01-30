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
    public var selectedType: RiderType = .rider
    public var avatarImage: Data?
    
    // Base location fields
    public var locationName: String = ""
    public var latitudeText: String = ""
    public var longitudeText: String = ""
    
    // MARK: - Dependencies
    
    private let riderService: any RiderServiceProtocol
    private let authState: AuthState
    
    // MARK: - Init
    
    public init(riderService: any RiderServiceProtocol, authState: AuthState) {
        self.riderService = riderService
        self.authState = authState
    }
    
    // MARK: - Load Data
    
    /// Load all profile data
    public func loadProfile() async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Load rider profile
        do {
            let fetchedRider = try await riderService.fetchMyRider()
            rider = fetchedRider
            populateFieldsFromRider(fetchedRider)
        } catch {
            self.error = "Failed to load profile: \(error.localizedDescription)"
            return
        }
        
        // Load base location (optional - may not exist)
        do {
            baseLocation = try await riderService.fetchMyBaseLocation()
            if let location = baseLocation {
                populateLocationFields(location)
            }
        } catch {
            // Non-critical - user may not have set a location
            baseLocation = nil
        }
        
        // Load sports
        await loadSports()
    }
    
    /// Load available sports and user's sports
    public func loadSports() async {
        do {
            async let fetchedAllSports = riderService.fetchAllSports()
            async let fetchedRiderSports = riderService.fetchMyRiderSports()
            
            allSports = try await fetchedAllSports
            riderSports = try await fetchedRiderSports
        } catch {
            // Non-critical for sports
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
            type: selectedType,
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: trimmedDescription.isEmpty ? nil : trimmedDescription
        )
        
        do {
            let updatedRider = try await riderService.updateMyRider(request)
            rider = updatedRider
            successMessage = "Profile updated successfully"
            
            // Refresh authState rider
            await authState.fetchRiderProfile()
        } catch {
            self.error = "Failed to update profile: \(error.localizedDescription)"
        }
    }
    
    /// Upload avatar image
    public func uploadAvatar() async {
        guard let imageData = avatarImage else {
            error = "No image selected"
            return
        }
        
        isUploadingAvatar = true
        error = nil
        
        defer { isUploadingAvatar = false }
        
        do {
            let response = try await riderService.uploadAvatar(imageData)
            
            // Update local rider with new avatar URL
            if let currentRider = rider {
                self.rider = Rider(
                    id: currentRider.id,
                    userId: currentRider.userId,
                    type: currentRider.type,
                    displayName: currentRider.displayName,
                    description: currentRider.description,
                    avatarUrl: response.avatarUrl,
                    createdAt: currentRider.createdAt,
                    updatedAt: Date()
                )
            }
            
            successMessage = "Avatar uploaded successfully"
            avatarImage = nil
            
            await authState.fetchRiderProfile()
        } catch {
            self.error = "Failed to upload avatar: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Base Location
    
    /// Save base location
    public func saveBaseLocation() async {
        guard validateLocationFields() else { return }
        
        guard let lat = Double(latitudeText),
              let lng = Double(longitudeText) else {
            error = "Invalid coordinates"
            return
        }
        
        isSaving = true
        error = nil
        
        defer { isSaving = false }
        
        let request = UpdateBaseLocationRequest(
            latitude: lat,
            longitude: lng,
            name: locationName.isEmpty ? nil : locationName
        )
        
        do {
            let updated = try await riderService.updateMyBaseLocation(request)
            baseLocation = updated
            successMessage = "Location saved successfully"
        } catch {
            self.error = "Failed to save location: \(error.localizedDescription)"
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
            let updatedSport = try await riderService.upsertMyRiderSport(sportId: sportId, request: request)
            
            // Update local list
            if let index = riderSports.firstIndex(where: { $0.sportId == sportId }) {
                riderSports[index] = updatedSport
            } else {
                riderSports.append(updatedSport)
            }
        } catch {
            self.error = "Failed to update sport: \(error.localizedDescription)"
        }
    }
    
    /// Remove a sport
    public func removeSport(sportId: String) async {
        sportLoadingIds.insert(sportId)
        error = nil
        
        defer { sportLoadingIds.remove(sportId) }
        
        do {
            try await riderService.deleteMyRiderSport(sportId: sportId)
            riderSports.removeAll { $0.sportId == sportId }
        } catch {
            self.error = "Failed to remove sport: \(error.localizedDescription)"
        }
    }
    
    /// Check if a sport is currently loading
    public func isSportLoading(_ sportId: String) -> Bool {
        sportLoadingIds.contains(sportId)
    }
    
    /// Get rider's sport by sportId
    public func riderSport(for sportId: String) -> RiderSport? {
        riderSports.first { $0.sportId == sportId }
    }
    
    // MARK: - Delete Account
    
    /// Delete user account
    public func deleteAccount() async {
        isLoading = true
        error = nil
        
        do {
            try await riderService.deleteMyAccount()
            await authState.handleSessionInvalidation()
        } catch {
            self.error = "Failed to delete account: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Helpers
    
    private func populateFieldsFromRider(_ rider: Rider) {
        displayName = rider.displayName ?? ""
        description = rider.description ?? ""
        selectedType = rider.type ?? .rider
    }
    
    private func populateLocationFields(_ location: RiderBaseLocation) {
        locationName = location.name ?? ""
        latitudeText = String(format: "%.6f", location.latitude)
        longitudeText = String(format: "%.6f", location.longitude)
    }
    
    private func validateProfileFields() -> Bool {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            error = "Display name is required"
            return false
        }
        
        if trimmed.count > 40 {
            error = "Display name must be 40 characters or less"
            return false
        }
        
        if description.count > 1000 {
            error = "Description must be 1000 characters or less"
            return false
        }
        
        return true
    }
    
    private func validateLocationFields() -> Bool {
        guard let lat = Double(latitudeText),
              let lng = Double(longitudeText) else {
            error = "Please enter valid coordinates"
            return false
        }
        
        if lat < -90 || lat > 90 {
            error = "Latitude must be between -90 and 90"
            return false
        }
        
        if lng < -180 || lng > 180 {
            error = "Longitude must be between -180 and 180"
            return false
        }
        
        return true
    }
    
    public func clearMessages() {
        error = nil
        successMessage = nil
    }
}
