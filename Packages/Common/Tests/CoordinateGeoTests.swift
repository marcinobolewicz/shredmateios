import XCTest
import CoreLocation
@testable import Common

final class CoordinateGeoTests: XCTestCase {

    private let warsaw = CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122)

    func testDistanceToSelfIsZero() {
        XCTAssertEqual(warsaw.distance(to: warsaw), 0, accuracy: 0.01)
    }

    func testDistanceMatchesCoreLocation() {
        let krakow = CLLocationCoordinate2D(latitude: 50.0647, longitude: 19.9450)
        let expected = CLLocation(latitude: warsaw.latitude, longitude: warsaw.longitude)
            .distance(from: CLLocation(latitude: krakow.latitude, longitude: krakow.longitude))
        XCTAssertEqual(warsaw.distance(to: krakow), expected, accuracy: 0.01)
    }

    func testOffsetNorthByKnownDistance() {
        let meters = 1_000.0
        let moved = warsaw.offset(byMeters: meters, bearing: 0)
        XCTAssertEqual(warsaw.distance(to: moved), meters, accuracy: 0.5)
        XCTAssertGreaterThan(moved.latitude, warsaw.latitude)
        XCTAssertEqual(moved.longitude, warsaw.longitude, accuracy: 0.0001)
    }

    func testOffsetEastMovesLongitude() {
        let moved = warsaw.offset(byMeters: 500, bearing: .pi / 2)
        XCTAssertEqual(warsaw.distance(to: moved), 500, accuracy: 0.5)
        XCTAssertGreaterThan(moved.longitude, warsaw.longitude)
        XCTAssertEqual(moved.latitude, warsaw.latitude, accuracy: 0.0001)
    }

    func testRandomOffsetStaysWithinRadius() {
        var rng = SystemRandomNumberGenerator()
        for _ in 0..<200 {
            let moved = warsaw.randomOffset(radiusMeters: 100, using: &rng)
            XCTAssertLessThanOrEqual(warsaw.distance(to: moved), 100.5)
        }
    }

    func testRandomOffsetProducesVariedResults() {
        var rng = SystemRandomNumberGenerator()
        let samples = (0..<50).map { _ in warsaw.randomOffset(radiusMeters: 100, using: &rng) }
        let uniqueLatitudes = Set(samples.map { String(format: "%.6f", $0.latitude) })
        XCTAssertGreaterThan(uniqueLatitudes.count, 10)
    }
}
