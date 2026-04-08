import Foundation
import Networking
import Common

enum DateRangePreset: String, CaseIterable, Identifiable {
    case thisWeek
    case nextWeek
    case thisAndNext

    var id: String { rawValue }

    var label: String {
        switch self {
        case .thisWeek: return ProfileStrings.presetThisWeek.localized
        case .nextWeek: return ProfileStrings.presetNextWeek.localized
        case .thisAndNext: return ProfileStrings.presetThisAndNext.localized
        }
    }

    func dateRange() -> (start: String, end: String) {
        let today = Date()
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: today)
        let daysToMonday = weekday == 1 ? -6 : (2 - weekday)
        let thisMonday = cal.date(byAdding: .day, value: daysToMonday, to: cal.startOfDay(for: today))!
        let fmt = DateFormatting.shared

        switch self {
        case .thisWeek:
            let sunday = cal.date(byAdding: .day, value: 6, to: thisMonday)!
            return (fmt.formatDateOnly(thisMonday), fmt.formatDateOnly(sunday))
        case .nextWeek:
            let nextMon = cal.date(byAdding: .day, value: 7, to: thisMonday)!
            let nextSun = cal.date(byAdding: .day, value: 13, to: thisMonday)!
            return (fmt.formatDateOnly(nextMon), fmt.formatDateOnly(nextSun))
        case .thisAndNext:
            let nextSun = cal.date(byAdding: .day, value: 13, to: thisMonday)!
            return (fmt.formatDateOnly(thisMonday), fmt.formatDateOnly(nextSun))
        }
    }
}

enum SlotDuration: Int, CaseIterable, Identifiable {
    case thirty = 30
    case sixty = 60

    var id: Int { rawValue }
    var label: String { "\(rawValue) min" }
}

struct Weekday: Identifiable, Sendable {
    let id: Int
    let label: String
}

@MainActor
@Observable
final class GenerateSlotsViewModel {

    // MARK: - Form State

    var selectedSport: Sport?
    var selectedPlace: PlaceDto?
    var selectedWeekdays: Set<Int> = []
    var datePreset: DateRangePreset = .nextWeek
    var timeFrom = DateComponents(hour: 14, minute: 0)
    var timeTo = DateComponents(hour: 18, minute: 0)
    var duration: SlotDuration = .sixty
    var priceText = "150"

    // MARK: - UI State

    private(set) var isSubmitting = false
    var actionError: AppError?
    var result: GenerateSlotsResponse?
    var validationError: String?

    // MARK: - Data

    private(set) var mentorSports: [Sport] = []
    private(set) var places: [PlaceDto] = []

    // MARK: - Dependencies

    private let mentorSlotsService: MentorSlotsServiceProtocol
    private let placesService: PlacesServiceProtocol

    static let weekdays: [Weekday] = {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        // API: 0=Sun, 1=Mon...6=Sat — reorder to Mon-first display
        return [1, 2, 3, 4, 5, 6, 0].map { Weekday(id: $0, label: symbols[$0]) }
    }()

    init(
        mentorSlotsService: MentorSlotsServiceProtocol,
        placesService: PlacesServiceProtocol,
        riderSports: [RiderSport]
    ) {
        self.mentorSlotsService = mentorSlotsService
        self.placesService = placesService
        self.mentorSports = riderSports.filter(\.isMentor).compactMap(\.sport)
        if mentorSports.count == 1 {
            selectedSport = mentorSports.first
        }
    }

    // MARK: - Data Loading

    func loadPlaces() async {
        do {
            places = try await placesService.fetchPlaces(sportSlug: nil)
        } catch {
            places = []
        }
    }

    // MARK: - Weekday Helpers

    func toggleWeekday(_ id: Int) {
        if selectedWeekdays.contains(id) {
            selectedWeekdays.remove(id)
        } else {
            selectedWeekdays.insert(id)
        }
    }

    func selectWorkdays() {
        selectedWeekdays = [1, 2, 3, 4, 5]
    }

    func selectAllDays() {
        selectedWeekdays = [0, 1, 2, 3, 4, 5, 6]
    }

    // MARK: - Time Helpers

    var timeFromDate: Date {
        get { Calendar.current.date(from: timeFrom) ?? Date() }
        set { timeFrom = Calendar.current.dateComponents([.hour, .minute], from: newValue) }
    }

    var timeToDate: Date {
        get { Calendar.current.date(from: timeTo) ?? Date() }
        set { timeTo = Calendar.current.dateComponents([.hour, .minute], from: newValue) }
    }

    /// Converts local time components to a UTC `"HH:mm"` string.
    private func localTimeToUTC(_ components: DateComponents) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let localDate = calendar.date(
            bySettingHour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: 0,
            of: today
        ) else {
            return DateFormatting.shared.formatTimeComponents(components)
        }
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        let utcHour = utcCalendar.component(.hour, from: localDate)
        let utcMinute = utcCalendar.component(.minute, from: localDate)
        return String(format: "%02d:%02d", utcHour, utcMinute)
    }

    // MARK: - Submit

    func generate() async {
        validationError = nil

        guard let sport = selectedSport else {
            validationError = ProfileStrings.generateValidationSport.localized
            return
        }
        guard !selectedWeekdays.isEmpty else {
            validationError = ProfileStrings.generateValidationWeekdays.localized
            return
        }

        let fromStr = DateFormatting.shared.formatTimeComponents(timeFrom)
        let toStr = DateFormatting.shared.formatTimeComponents(timeTo)
        guard fromStr < toStr else {
            validationError = ProfileStrings.generateValidationTime.localized
            return
        }

        let priceValue = Int(priceText) ?? 0
        guard priceValue > 0 else {
            validationError = ProfileStrings.generateValidationPrice.localized
            return
        }

        let utcFrom = localTimeToUTC(timeFrom)
        let utcTo = localTimeToUTC(timeTo)
        let range = datePreset.dateRange()

        let request = GenerateSlotsRequest(
            sportId: sport.id.uuidString.lowercased(),
            placeId: selectedPlace?.id.uuidString.lowercased(),
            weekdays: Array(selectedWeekdays).sorted(),
            timeFrom: utcFrom,
            timeTo: utcTo,
            duration: duration.rawValue,
            price: priceValue * 100,
            startDate: range.start,
            endDate: range.end
        )

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            result = try await mentorSlotsService.generateSlots(request: request)
        } catch {
            actionError = .from(error)
        }
    }

}
