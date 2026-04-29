@testable import Profile
import Networking
import XCTest

final class MyBookingsViewModelTests: XCTestCase {

    private let start = ISO8601DateFormatter().date(from: "2026-04-18T14:00:00Z")!
    private let end = ISO8601DateFormatter().date(from: "2026-04-18T15:00:00Z")!

    func testCanReject_beforeStart_false() {
        let now = start.addingTimeInterval(-60)
        XCTAssertFalse(MyBookingsViewModel.canReject(now: now, startTime: start, endTime: end))
    }

    func testCanReject_atStart_true() {
        XCTAssertTrue(MyBookingsViewModel.canReject(now: start, startTime: start, endTime: end))
    }

    func testCanReject_duringSession_true() {
        let now = start.addingTimeInterval(30 * 60)
        XCTAssertTrue(MyBookingsViewModel.canReject(now: now, startTime: start, endTime: end))
    }

    func testCanReject_atEnd_true() {
        XCTAssertTrue(MyBookingsViewModel.canReject(now: end, startTime: start, endTime: end))
    }

    func testCanReject_atDeadlineBoundary_true() {
        let deadline = end.addingTimeInterval(MyBookingsViewModel.rejectWindowSeconds)
        XCTAssertTrue(MyBookingsViewModel.canReject(now: deadline, startTime: start, endTime: end))
    }

    func testCanReject_pastDeadline_false() {
        let past = end.addingTimeInterval(MyBookingsViewModel.rejectWindowSeconds + 1)
        XCTAssertFalse(MyBookingsViewModel.canReject(now: past, startTime: start, endTime: end))
    }
}
