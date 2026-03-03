import Foundation
import Networking

struct PlaceRiderRowPresenter: Sendable {
    func map(_ entry: PlaceRiderPresence) -> PlaceRiderRowViewData {
        let name = (entry.rider.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 } ?? "Rider"
        let roleText = roleLabel(entry.role)
        var parts: [String] = [entry.sport.name, roleText]

        if let rating = entry.rating {
            parts.append(String(format: "%.1f", rating))
        }

        return PlaceRiderRowViewData(
            id: entry.id,
            riderId: entry.rider.id,
            userId: entry.rider.userId,
            displayName: name,
            avatarInitials: initials(from: name),
            avatarURL: entry.rider.avatarUrl.flatMap(URL.init(string:)),
            subtitle: parts.joined(separator: " • ")
        )
    }

    private func roleLabel(_ role: PlaceRiderRole?) -> String {
        switch role {
        case .mentor:
            return PlacesStrings.roleMentor.localized
        default:
            return PlacesStrings.roleRider.localized
        }
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
