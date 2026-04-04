import Foundation
import Networking
import Common

struct MentorSlotPresenter: Sendable {

    private let dateFormatting = DateFormatting.shared

    func groupByDay(_ slots: [MentorSlot]) -> [MentorSlotDayGroup] {
        let grouped = Dictionary(grouping: slots) { dateFormatting.dayKey(from: $0.startTime) }
        return grouped.keys.sorted().compactMap { key in
            guard let daySlots = grouped[key] else { return nil }
            let header = dateFormatting.formatDayHeader(dateString: key)
            let rows = daySlots
                .sorted { $0.startTime < $1.startTime }
                .map { mapSlot($0, dayHeader: header) }
            return MentorSlotDayGroup(dayHeader: header, slots: rows)
        }
    }

    private func mapSlot(_ slot: MentorSlot, dayHeader: String) -> MentorSlotRowViewData {
        let timeRange = "\(dateFormatting.localizedTime(from: slot.startTime))\u{2013}\(dateFormatting.localizedTime(from: slot.endTime))"
        return MentorSlotRowViewData(
            id: slot.id,
            startTime: slot.startTime,
            timeRange: timeRange,
            duration: "\(slot.duration) min",
            price: formatPrice(slot.price, currency: slot.currency),
            sportName: slot.sport.name,
            placeName: slot.place?.name,
            dayHeader: dayHeader
        )
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
