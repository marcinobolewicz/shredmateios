import Foundation
import Networking

struct ProfileFormData: Sendable {
    let displayName: String
    let description: String
    let isPublic: Bool
}

struct ProfileLocationFormData: Sendable {
    let latitudeText: String
    let longitudeText: String
}

struct ProfileFormPresenter: Sendable {
    func mapProfileForm(from rider: Rider) -> ProfileFormData {
        ProfileFormData(
            displayName: rider.displayName ?? "",
            description: rider.description ?? "",
            isPublic: rider.isPublic ?? true
        )
    }

    func mapLocationForm(from location: RiderBaseLocation?) -> ProfileLocationFormData {
        guard let location else {
            return ProfileLocationFormData(latitudeText: "", longitudeText: "")
        }

        return ProfileLocationFormData(
            latitudeText: String(format: "%.6f", location.latitude),
            longitudeText: String(format: "%.6f", location.longitude)
        )
    }

    func riderAfterAvatarUpload(current: Rider?, avatarURL: String) -> Rider? {
        guard let current else { return nil }

        return Rider(
            id: current.id,
            userId: current.userId,
            type: current.type,
            displayName: current.displayName,
            description: current.description,
            avatarUrl: avatarURL,
            isPublic: current.isPublic,
            createdAt: current.createdAt,
            updatedAt: Date()
        )
    }
}
