import Foundation
import Networking

@MainActor
@Observable
final class MentorSlotsViewModel {

    private(set) var dayGroups: [MentorSlotDayGroup] = []
    private(set) var isLoading = false
    private(set) var hasSlots = false

    private let mentorRiderId: String
    private let service: MentorSlotsServiceProtocol
    private let presenter = MentorSlotPresenter()

    init(mentorRiderId: String, service: MentorSlotsServiceProtocol) {
        self.mentorRiderId = mentorRiderId
        self.service = service
    }

    func loadSlots() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let now = ISO8601DateFormatter().string(from: Date())
            let twoWeeks = ISO8601DateFormatter().string(
                from: Date(timeIntervalSinceNow: 14 * 24 * 60 * 60)
            )
            let response = try await service.fetchSlots(
                mentorRiderId: mentorRiderId,
                from: now,
                to: twoWeeks,
                limit: 100
            )
            dayGroups = presenter.groupByDay(response.items)
            hasSlots = !response.items.isEmpty
        } catch {
            dayGroups = []
            hasSlots = false
        }
    }
}
