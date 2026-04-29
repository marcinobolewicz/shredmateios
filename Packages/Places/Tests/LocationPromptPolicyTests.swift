import XCTest
import CoreLocation
import Common
import Networking
@testable import Places

final class LocationPromptPolicyTests: XCTestCase {

    private let policy = LocationPromptPolicy.default
    private let spot = CLLocationCoordinate2D(latitude: 52.2297, longitude: 21.0122)

    func testPromptsWhenBaseLocationMissing() {
        XCTAssertTrue(policy.shouldPrompt(current: nil, spot: spot))
    }

    func testDoesNotPromptWhenBaseLocationAtSpot() {
        let current = RiderBaseLocation(latitude: spot.latitude, longitude: spot.longitude)
        XCTAssertFalse(policy.shouldPrompt(current: current, spot: spot))
    }

    func testDoesNotPromptWhenBaseLocationWithinThreshold() {
        let nearby = spot.offset(byMeters: 400, bearing: 0)
        let current = RiderBaseLocation(latitude: nearby.latitude, longitude: nearby.longitude)
        XCTAssertFalse(policy.shouldPrompt(current: current, spot: spot))
    }

    func testPromptsWhenBaseLocationBeyondThreshold() {
        let far = spot.offset(byMeters: 1_200, bearing: .pi / 2)
        let current = RiderBaseLocation(latitude: far.latitude, longitude: far.longitude)
        XCTAssertTrue(policy.shouldPrompt(current: current, spot: spot))
    }

    func testAutoUpdateCoordinateStaysWithinConfiguredRadius() {
        for _ in 0..<50 {
            let candidate = policy.autoUpdateCoordinate(for: spot)
            XCTAssertLessThanOrEqual(spot.distance(to: candidate), policy.autoUpdateRadiusMeters + 0.5)
        }
    }
}
