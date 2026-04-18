import Foundation
import Common

enum SlotTimeScope: Sendable, Equatable {
    case current
    case archive

    var toggled: SlotTimeScope {
        switch self {
        case .current: .archive
        case .archive: .current
        }
    }

    var toggleActionTitle: String {
        switch self {
        case .current: ProfileStrings.scopeShowArchive.localized
        case .archive: ProfileStrings.scopeShowCurrent.localized
        }
    }

    func dateRange(now: Date = Date(), calendar: Calendar = .current) -> (from: String?, to: String?) {
        let fmt = DateFormatting.shared
        switch self {
        case .current:
            return (fmt.formatISO8601(calendar.startOfDay(for: now)), nil)
        case .archive:
            return (nil, fmt.formatISO8601(now))
        }
    }
}
