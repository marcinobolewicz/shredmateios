import Foundation

struct PlaceRiderRowViewData: Identifiable, Equatable, Sendable {
    let id: String
    let displayName: String
    let avatarInitials: String
    let avatarURL: URL?
    let subtitle: String
}
