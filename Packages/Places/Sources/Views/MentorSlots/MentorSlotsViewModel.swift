import Foundation
import Networking
import Common

@MainActor
@Observable
public final class MentorSlotsViewModel {

    private(set) var dayGroups: [MentorSlotDayGroup] = []
    private(set) var isLoading = false
    private(set) var hasSlots = false
    private(set) var sessionCount: Int?
    private(set) var recommendationCount: Int?
    
    var actionError: String?
    var selectedSlot: MentorSlotRowViewData?
    var showDeleteConfirmation = false
    var showBookConfirmation = false
    var showBookingTooSoon = false

    let isOwner: Bool

    private let mentorRiderId: String
    private let service: MentorSlotsServiceProtocol
    private let presenter = MentorSlotPresenter()

    init(
        mentorRiderId: String,
        currentRiderId: String?,
        service: MentorSlotsServiceProtocol
    ) {
        self.mentorRiderId = mentorRiderId
        self.isOwner = currentRiderId != nil && currentRiderId == mentorRiderId
        self.service = service
    }

    func loadSlots() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        await fetchSlots()
    }

    func refresh() async {
        await fetchSlots()
    }

    private func fetchSlots() async {
        do {
            let fmt = DateFormatting.shared
            let now = fmt.formatISO8601(Date())
            let twoWeeks = fmt.formatISO8601(
                Date(timeIntervalSinceNow: 14 * 24 * 60 * 60)
            )
            let response = try await service.fetchSlots(
                mentorRiderId: mentorRiderId,
                from: now,
                to: twoWeeks,
                limit: 100
            )
            let mentorRider = response.items.first?.mentorRider
            sessionCount = mentorRider?.sessionCount
            recommendationCount = mentorRider?.recommendationCount
            dayGroups = presenter.groupByDay(response.items)
            hasSlots = !response.items.isEmpty
        } catch {
            dayGroups = []
            hasSlots = false
        }
    }

    func slotTapped(_ slot: MentorSlotRowViewData) {
        selectedSlot = slot
        if isOwner {
            showDeleteConfirmation = true
        } else {
            let start = DateFormatting.shared.parseISO8601(slot.startTime) ?? .distantPast
            let minutesLeft = start.timeIntervalSince(Date()) / 60
            if minutesLeft < 30 {
                showBookingTooSoon = true
            } else {
                showBookConfirmation = true
            }
        }
    }

    func confirmDelete() async {
        guard let slot = selectedSlot else { return }
        actionError = nil
        do {
            try await service.deleteSlot(id: slot.id)
            await loadSlots()
        } catch {
            actionError = error.localizedDescription
        }
        selectedSlot = nil
    }

    func confirmBook() async {
        guard let slot = selectedSlot else { return }
        actionError = nil
        do {
            _ = try await service.bookSlot(id: slot.id)
            await loadSlots()
        } catch {
            actionError = error.localizedDescription
        }
        selectedSlot = nil
    }

    func dismissAction() {
        selectedSlot = nil
        showDeleteConfirmation = false
        showBookConfirmation = false
        showBookingTooSoon = false
    }
}
