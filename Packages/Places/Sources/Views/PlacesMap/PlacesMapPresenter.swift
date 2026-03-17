import Foundation
import MapKit

struct PlaceMapPinViewData: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String
    let description: String
    let placeDetailsData: PlaceDetailsViewData
}

struct PlacesMapPresenter {
    let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.0647, longitude: 19.9450),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    func mapPins(from rows: [SpotRowViewData]) -> [PlaceMapPinViewData] {
        rows.compactMap { row in
            guard let latitude = row.latitude, let longitude = row.longitude else {
                return nil
            }

            let infoText: String
            if row.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                infoText = "\(PlacesStrings.ridersLabel.localized): \(row.ridersCount) • \(PlacesStrings.mentorsLabel.localized): \(row.mentorsCount)"
            } else {
                infoText = row.description
            }

            return PlaceMapPinViewData(
                id: row.id,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                title: row.title,
                description: infoText,
                placeDetailsData: PlaceDetailsViewData(
                    id: row.id,
                    name: row.title,
                    description: row.description,
                    sportTags: row.sportTags,
                    placeTags: row.placeTags,
                    sportIds: row.sportIds,
                    sportSlugs: row.sportSlugs,
                    ridersCount: row.ridersCount,
                    mentorsCount: row.mentorsCount,
                    avatar: row.avatar
                )
            )
        }
    }

    func region(for pins: [PlaceMapPinViewData], fallback: MKCoordinateRegion) -> MKCoordinateRegion {
        guard !pins.isEmpty else { return fallback }

        let latitudes = pins.map(\.coordinate.latitude)
        let longitudes = pins.map(\.coordinate.longitude)

        guard
            let minLat = latitudes.min(),
            let maxLat = latitudes.max(),
            let minLng = longitudes.min(),
            let maxLng = longitudes.max()
        else {
            return fallback
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )

        let latitudeDelta = max((maxLat - minLat) * 1.4, 0.03)
        let longitudeDelta = max((maxLng - minLng) * 1.4, 0.03)

        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: latitudeDelta,
                longitudeDelta: longitudeDelta
            )
        )
    }
}
