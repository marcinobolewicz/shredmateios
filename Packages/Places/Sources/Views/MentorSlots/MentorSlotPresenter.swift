import Foundation
import Networking

struct MentorSlotPresenter: Sendable {

    func groupByDay(_ slots: [MentorSlot]) -> [MentorSlotDayGroup] {
        let grouped = Dictionary(grouping: slots) { dayKey($0.startTime) }
        return grouped.keys.sorted().compactMap { key in
            guard let daySlots = grouped[key] else { return nil }
            let header = formatDayHeader(key)
            let rows = daySlots
                .sorted { $0.startTime < $1.startTime }
                .map { mapSlot($0, dayHeader: header) }
            return MentorSlotDayGroup(dayHeader: header, slots: rows)
        }
    }

    private func mapSlot(_ slot: MentorSlot, dayHeader: String) -> MentorSlotRowViewData {
        MentorSlotRowViewData(
            id: slot.id,
            timeRange: formatTimeRange(start: slot.startTime, end: slot.endTime),
            duration: formatDuration(slot.duration),
            price: formatPrice(slot.price, currency: slot.currency),
            sportName: slot.sport.name,
            placeName: slot.place?.name,
            dayHeader: dayHeader
        )
    }

    // MARK: - Formatting

    private func dayKey(_ isoString: String) -> String {
        String(isoString.prefix(10))
    }

    private func formatDayHeader(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale.current
        guard let date = formatter.date(from: dateString) else { return dateString }
        let display = DateFormatter()
        display.locale = Locale.current
        display.setLocalizedDateFormatFromTemplate("EEEEddMMMM")
        return display.string(from: date).localizedCapitalized
    }

    private func formatTimeRange(start: String, end: String) -> String {
        "\(formatTime(start))\u{2013}\(formatTime(end))"
    }

    private func formatTime(_ isoString: String) -> String {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = parser.date(from: isoString) else {
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            guard let date = fallback.date(from: isoString) else { return "--:--" }
            return timeString(from: date)
        }
        return timeString(from: date)
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ minutes: Int) -> String {
        "\(minutes) min"
    }

    private func formatPrice(_ grosz: Int, currency: String) -> String {
        let value = Double(grosz) / 100.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) \(currency)"
    }
}
