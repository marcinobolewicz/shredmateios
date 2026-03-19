import SwiftUI
import MapKit
import Theme
import Networking
import Common

struct PlaceDetailsMapView: View {
    @Environment(AppTheme.self) private var theme

    let viewData: PlaceDetailsViewData
    let riderEntries: [PlaceRiderPresence]

    private static let nearbyRadiusMeters: Double = 10_000

    var body: some View {
        Map(coordinateRegion: .constant(region), annotationItems: annotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate, anchorPoint: CGPoint(x: 0.5, y: 1.0)) {
                switch annotation.kind {
                case .spot:
                    spotPin
                case .rider(let initials, let avatarURL):
                    riderPin(initials: initials, avatarURL: avatarURL)
                }
            }
        }
    }

    // MARK: - Annotations

    private var annotations: [PlaceDetailsAnnotation] {
        var result: [PlaceDetailsAnnotation] = []

        if let lat = viewData.latitude, let lng = viewData.longitude {
            result.append(PlaceDetailsAnnotation(
                id: "spot",
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                kind: .spot
            ))
        }

        guard let spotLat = viewData.latitude, let spotLng = viewData.longitude else {
            return result
        }

        let spotLocation = CLLocation(latitude: spotLat, longitude: spotLng)

        for entry in riderEntries {
            guard let base = entry.rider.baseLocation else { continue }
            let riderLocation = CLLocation(latitude: base.lat, longitude: base.lng)
            guard riderLocation.distance(from: spotLocation) <= Self.nearbyRadiusMeters else { continue }

            let name = entry.rider.displayName ?? "?"
            let initials = initials(from: name)
            let avatarURL = entry.rider.avatarUrl.flatMap(URL.init)

            result.append(PlaceDetailsAnnotation(
                id: entry.rider.id.uuidString,
                coordinate: CLLocationCoordinate2D(latitude: base.lat, longitude: base.lng),
                kind: .rider(initials: initials, avatarURL: avatarURL)
            ))
        }

        return result
    }

    private var region: MKCoordinateRegion {
        guard let lat = viewData.latitude, let lng = viewData.longitude else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 50.0647, longitude: 19.9450),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
        // ~10km radius
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            latitudinalMeters: 22_000,
            longitudinalMeters: 22_000
        )
    }

    // MARK: - Pin Views

    private var spotPin: some View {
        Image(systemName: "mappin.and.ellipse.circle.fill")
            .font(.system(size: 32))
            .foregroundStyle(theme.colors.primary)
            .background(Circle().fill(.white).padding(4))
    }

    private func riderPin(initials: String, avatarURL: URL?) -> some View {
        AvatarView(url: avatarURL, initials: initials, size: 36)
            .overlay(Circle().stroke(theme.colors.primary, lineWidth: 2))
            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }
}

// MARK: - Annotation Model

private struct PlaceDetailsAnnotation: Identifiable {
    enum Kind {
        case spot
        case rider(initials: String, avatarURL: URL?)
    }

    let id: String
    let coordinate: CLLocationCoordinate2D
    let kind: Kind
}
