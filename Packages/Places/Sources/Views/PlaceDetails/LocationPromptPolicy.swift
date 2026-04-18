import CoreLocation
import Common
import Networking

struct LocationPromptPolicy: Sendable {

    /// Prompt if base location is missing or farther than this from the spot.
    let promptThresholdMeters: CLLocationDistance
    /// Radius of the randomized auto-update offset.
    let autoUpdateRadiusMeters: CLLocationDistance

    static let `default` = LocationPromptPolicy(
        promptThresholdMeters: 500,
        autoUpdateRadiusMeters: 100
    )

    func shouldPrompt(current: RiderBaseLocation?, spot: CLLocationCoordinate2D) -> Bool {
        guard let current else { return true }
        let currentCoord = CLLocationCoordinate2D(
            latitude: current.latitude,
            longitude: current.longitude
        )
        return currentCoord.distance(to: spot) > promptThresholdMeters
    }

    func autoUpdateCoordinate(for spot: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        spot.randomOffset(radiusMeters: autoUpdateRadiusMeters)
    }
}
