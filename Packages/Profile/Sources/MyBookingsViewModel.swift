import Foundation
import Networking
import Common

@MainActor
@Observable
final class MyBookingsViewModel {

    private(set) var slots: [MentorSlot] = []
    private(set) var state: LoadState = .idle
    var actionError: AppError?

    var selectedSlot: MentorSlot?
    var showCancelConfirmation = false
    var showCompleteConfirmation = false

    private let service: MentorSlotsServiceProtocol

    init(service: MentorSlotsServiceProtocol) {
        self.service = service
    }

    func loadOnAppear() {
        guard state == .idle else { return }
        Task { await load() }
    }

    func refresh() {
        Task { await load() }
    }

    // MARK: - Slot Actions

    func action(for slot: MentorSlot) -> BookingAction? {
        switch slot.status {
        case .booked:
            let start = ISO8601DateFormatter().date(from: slot.startTime) ?? .distantPast
            if start > Date() {
                let hoursLeft = start.timeIntervalSince(Date()) / 3600
                return hoursLeft >= 2 ? .cancel : .tooLateToCancel
            } else {
                return .complete
            }
        case .completed:
            return .completed(slot.recommendationStatus)
        default:
            return nil
        }
    }

    func cancelTapped(_ slot: MentorSlot) {
        selectedSlot = slot
        showCancelConfirmation = true
    }

    func completeTapped(_ slot: MentorSlot) {
        selectedSlot = slot
        showCompleteConfirmation = true
    }

    func confirmCancel() async {
        guard let slot = selectedSlot else { return }
        do {
            _ = try await service.cancelBooking(id: slot.id)
            await load()
        } catch {
            actionError = .from(error)
        }
        selectedSlot = nil
    }

    func confirmComplete(recommend: Bool) async {
        guard let slot = selectedSlot else { return }
        do {
            _ = try await service.completeSession(id: slot.id, recommend: recommend)
            await load()
        } catch {
            actionError = .from(error)
        }
        selectedSlot = nil
    }

    func dismissAction() {
        selectedSlot = nil
        showCancelConfirmation = false
        showCompleteConfirmation = false
    }

    // MARK: - Private

    private func load() async {
        state = .loading
        do {
            let response = try await service.fetchBookedByMe()
            slots = response.items
            state = .loaded
        } catch {
            state = .failed(.from(error))
        }
    }
}

// MARK: - BookingAction

enum BookingAction: Equatable {
    case cancel
    case tooLateToCancel
    case complete
    case completed(MentorSlotRecommendationStatus?)
}
