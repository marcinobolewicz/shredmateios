//
//  DateFormatting.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 24/02/2026.
//

import Foundation

/// Thread-safe, reusable date formatting utilities.
///
/// Uses `NSLock` to guard `DateFormatter` instances which are not `Sendable`.
/// Safe to use from any actor or thread.
///
/// Usage:
/// ```swift
/// let date = DateFormatting.shared.parseISO8601("2026-02-24T14:30:00.000Z")
/// let time = DateFormatting.shared.formatTime(date)       // "14:30"
/// let day  = DateFormatting.shared.formatDisplayDate(date) // "24.02.2026"
/// ```
public final class DateFormatting: @unchecked Sendable {

    public static let shared = DateFormatting()

    // MARK: - Private state

    private let lock = NSLock()

    private let _iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private let _time: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private let _displayDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d.MM.yyyy"
        return f
    }()

    private init() {}

    // MARK: - Parsing

    /// Parses an ISO 8601 date string with fractional seconds.
    public func parseISO8601(_ string: String) -> Date? {
        lock.withLock { _iso8601.date(from: string) }
    }

    // MARK: - Formatting

    /// Formats a date as time only, e.g. `"14:30"`.
    public func formatTime(_ date: Date) -> String {
        lock.withLock { _time.string(from: date) }
    }

    /// Formats a date for display, e.g. `"24.02.2026"`.
    public func formatDisplayDate(_ date: Date) -> String {
        lock.withLock { _displayDate.string(from: date) }
    }
}
