import Foundation

struct PlaceRiderRowViewData: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let riderId: UUID
    let userId: UUID
    let displayName: String
    let avatarInitials: String
    let avatarURL: URL?
    let subtitle: String

    var riderCardData: RiderCardViewData {
        RiderCardViewData(
            id: id,
            riderId: riderId,
            userId: userId,
            displayName: displayName,
            avatarInitials: avatarInitials,
            avatarURL: avatarURL,
            description: subtitle
        )
    }
}
