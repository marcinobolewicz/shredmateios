import CoreLocation
import Foundation

public extension CLLocationCoordinate2D {

    /// Great-circle distance in meters to another coordinate.
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }

    /// Returns a coordinate offset by `meters` along the given compass `bearing`.
    /// - Parameters:
    ///   - meters: distance along surface, must be non-negative
    ///   - bearing: compass bearing in radians (0 = north, π/2 = east)
    func offset(byMeters meters: CLLocationDistance, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6_371_000.0
        let angularDistance = meters / earthRadius

        let lat1 = latitude * .pi / 180
        let lon1 = longitude * .pi / 180

        let lat2 = asin(
            sin(lat1) * cos(angularDistance) +
            cos(lat1) * sin(angularDistance) * cos(bearing)
        )
        let lon2 = lon1 + atan2(
            sin(bearing) * sin(angularDistance) * cos(lat1),
            cos(angularDistance) - sin(lat1) * sin(lat2)
        )

        return CLLocationCoordinate2D(
            latitude: lat2 * 180 / .pi,
            longitude: lon2 * 180 / .pi
        )
    }

    /// Returns a coordinate offset by a uniformly distributed random bearing
    /// and a random distance in `(0, radiusMeters]`.
    func randomOffset<R: RandomNumberGenerator>(
        radiusMeters: CLLocationDistance,
        using generator: inout R
    ) -> CLLocationCoordinate2D {
        precondition(radiusMeters > 0, "radiusMeters must be positive")
        let bearing = Double.random(in: 0..<(2 * .pi), using: &generator)
        let distance = Double.random(in: 0...radiusMeters, using: &generator)
        return offset(byMeters: distance, bearing: bearing)
    }

    func randomOffset(radiusMeters: CLLocationDistance) -> CLLocationCoordinate2D {
        var generator = SystemRandomNumberGenerator()
        return randomOffset(radiusMeters: radiusMeters, using: &generator)
    }
}
