import Foundation
import Networking
import Common

enum MySlotFilter: String, CaseIterable, Sendable, Identifiable, ChipFilterOption {
    case available
    case booked
    case rejected
    case reservationPending

    var id: String { rawValue }

    var label: String {
        switch self {
        case .available: return ProfileStrings.statusAvailable.localized
        case .booked: return ProfileStrings.statusBooked.localized
        case .rejected: return ProfileStrings.statusRejected.localized
        case .reservationPending: return ProfileStrings.statusReservationPending.localized
        }
    }
}

struct MySlotDayGroup: Identifiable, Equatable {
    let id: String // date key "2026-03-28"
    let dayHeader: String
    let slots: [MentorSlot]
}

@MainActor
@Observable
final class MySlotsViewModel {

    private(set) var allSlots: [MentorSlot] = []
    private(set) var state: LoadState = .idle

    var filter: MySlotFilter?

    var selectedSlot: MentorSlot?
    var showDeleteConfirmation = false
    var actionError: AppError?

    private let service: MentorSlotsServiceProtocol

    init(service: MentorSlotsServiceProtocol) {
        self.service = service
    }

    // MARK: - Computed

    var dayGroups: [MySlotDayGroup] {
        let fmt = DateFormatting.shared
        let filtered = filteredSlots
        let grouped = Dictionary(grouping: filtered) { fmt.dayKey(from: $0.startTime) }
        return grouped.keys.sorted().compactMap { key in
            guard let slots = grouped[key] else { return nil }
            return MySlotDayGroup(
                id: key,
                dayHeader: fmt.formatDayHeader(dateString: key),
                slots: slots.sorted { $0.startTime < $1.startTime }
            )
        }
    }

    var isEmpty: Bool { filteredSlots.isEmpty }

    private var filteredSlots: [MentorSlot] {
        guard let filter else { return allSlots }
        switch filter {
        case .available: return allSlots.filter { $0.status == .available }
        case .booked: return allSlots.filter { $0.status == .booked }
        case .rejected: return allSlots.filter { $0.status == .rejected }
        case .reservationPending: return allSlots.filter { $0.status == .reservationPending }
        }
    }

    // MARK: - Actions

    func loadOnAppear() {
        guard state == .idle else { return }
        Task { await load() }
    }

    func refresh() {
        Task { await load() }
    }

    func deleteTapped(_ slot: MentorSlot) {
        guard slot.status == .available else { return }
        selectedSlot = slot
        showDeleteConfirmation = true
    }

    func confirmDelete() async {
        guard let slot = selectedSlot else { return }
        do {
            try await service.deleteSlot(id: slot.id)
            await load()
        } catch {
            actionError = .from(error)
        }
        selectedSlot = nil
    }

    func dismissAction() {
        selectedSlot = nil
        showDeleteConfirmation = false
    }

    // MARK: - Private

    private func load() async {
        state = .loading
        do {
            let response = try await service.fetchMySlots()
            allSlots = response.items
            state = .loaded
        } catch {
            state = .failed(.from(error))
        }
    }

}
