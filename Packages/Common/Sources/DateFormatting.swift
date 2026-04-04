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

    private let _iso8601Fractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private let _iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private let _time: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private let _localizedTime: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    private let _displayDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d.MM.yyyy"
        return f
    }()

    private let _dayHeader: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("EEEEddMMMM")
        return f
    }()

    private let _dateOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private let _relative: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f
    }()

    private let _absoluteRelative: DateFormatter = {
        let f = DateFormatter()
        f.locale = .current
        f.doesRelativeDateFormatting = true
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    private init() {}

    // MARK: - Parsing

    /// Parses an ISO 8601 date string (with or without fractional seconds).
    public func parseISO8601(_ string: String) -> Date? {
        lock.withLock {
            _iso8601Fractional.date(from: string) ?? _iso8601.date(from: string)
        }
    }

    // MARK: - API Request Formatting

    /// Formats a date as ISO 8601 UTC with fractional seconds for API requests.
    /// e.g. `"2026-03-31T14:00:00.000Z"`
    public func formatISO8601(_ date: Date) -> String {
        lock.withLock { _iso8601Fractional.string(from: date) }
    }

    /// Formats a date as date-only string for API requests.
    /// e.g. `"2026-03-31"`
    public func formatDateOnly(_ date: Date) -> String {
        lock.withLock { _dateOnly.string(from: date) }
    }

    /// Formats time components as `"HH:mm"` for API requests.
    /// e.g. `"14:00"`
    public func formatTimeComponents(_ components: DateComponents) -> String {
        String(format: "%02d:%02d", components.hour ?? 0, components.minute ?? 0)
    }

    // MARK: - Display Formatting

    /// Formats a date as fixed time `"HH:mm"`.
    public func formatTime(_ date: Date) -> String {
        lock.withLock { _time.string(from: date) }
    }

    /// Formats a date as locale-aware time, e.g. `"2:00 PM"` or `"14:00"`.
    public func formatLocalizedTime(_ date: Date) -> String {
        lock.withLock { _localizedTime.string(from: date) }
    }

    /// Formats a date for display, e.g. `"24.02.2026"`.
    public func formatDisplayDate(_ date: Date) -> String {
        lock.withLock { _displayDate.string(from: date) }
    }

    /// Formats a date as a localized day header, e.g. `"Monday 24 February"`.
    public func formatDayHeader(_ date: Date) -> String {
        lock.withLock { _dayHeader.string(from: date).localizedCapitalized }
    }

    /// Formats a `"yyyy-MM-dd"` date string as a localized day header.
    public func formatDayHeader(dateString: String) -> String {
        guard let date = lock.withLock({ _dateOnly.date(from: dateString) }) else {
            return dateString
        }
        return formatDayHeader(date)
    }

    /// Formats a date as relative time, e.g. `"2 hr. ago"`.
    public func formatRelativeTime(_ date: Date) -> String {
        lock.withLock { _relative.localizedString(for: date, relativeTo: .now) }
    }

    /// Formats a date as relative + absolute timestamp.
    /// e.g. `"2 hr. ago · Mar 31, 2026, 4:00 PM"`
    public func formatTimestamp(_ date: Date) -> String {
        let relative = lock.withLock { _relative.localizedString(for: date, relativeTo: .now) }
        let absolute = lock.withLock { _absoluteRelative.string(from: date) }
        return "\(relative) · \(absolute)"
    }

    // MARK: - ISO String Convenience

    /// Parses an ISO 8601 string and returns locale-aware time, or `"--:--"` on failure.
    public func localizedTime(from isoString: String) -> String {
        guard let date = parseISO8601(isoString) else { return "--:--" }
        return formatLocalizedTime(date)
    }

    /// Parses an ISO 8601 string and returns a localized day header.
    public func dayHeader(from isoString: String) -> String {
        guard let date = parseISO8601(isoString) else { return isoString }
        return formatDayHeader(date)
    }

    /// Parses an ISO 8601 string and returns relative time, or the original string on failure.
    public func relativeTime(from isoString: String) -> String {
        guard let date = parseISO8601(isoString) else { return isoString }
        return formatRelativeTime(date)
    }

    /// Parses an ISO 8601 string and returns a relative + absolute timestamp.
    public func timestamp(from isoString: String) -> String {
        guard let date = parseISO8601(isoString) else { return isoString }
        return formatTimestamp(date)
    }

    /// Extracts the `"yyyy-MM-dd"` day key from an ISO 8601 string.
    public func dayKey(from isoString: String) -> String {
        String(isoString.prefix(10))
    }
}
