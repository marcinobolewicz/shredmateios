import Foundation
import Networking
import Common

@MainActor
@Observable
final class MyBookingsViewModel {

    private(set) var allSlots: [MentorSlot] = []
    private(set) var state: LoadState = .idle
    private(set) var timeScope: SlotTimeScope = .current
    var actionError: AppError?

    var filter: MyBookingFilter?

    var selectedSlot: MentorSlot?
    var showCancelConfirmation = false
    var showCompleteConfirmation = false
    var showSessionNotStarted = false

    private let service: MentorSlotsServiceProtocol

    init(service: MentorSlotsServiceProtocol) {
        self.service = service
    }

    // MARK: - Computed

    var slots: [MentorSlot] {
        guard let filter else { return allSlots }
        switch filter {
        case .upcoming:
            return allSlots.filter { isBookedUpcoming($0) }
        case .toConfirm:
            return allSlots.filter { isBookedToConfirm($0) }
        case .finished:
            return allSlots.filter { $0.status == .completed }
        case .rejected:
            return allSlots.filter { $0.status == .rejected }
        case .reservationPending:
            return allSlots.filter { $0.status == .reservationPending }
        }
    }

    func loadOnAppear() {
        guard state == .idle else { return }
        Task { await load() }
    }

    func refresh() {
        Task { await load() }
    }

    func toggleScope() {
        timeScope = timeScope.toggled
        allSlots = []
        Task { await load() }
    }

    // MARK: - Slot Actions

    func action(for slot: MentorSlot) -> BookingAction? {
        switch slot.status {
        case .booked:
            let start = DateFormatting.shared.parseISO8601(slot.startTime) ?? .distantPast
            if start > Date() {
                let hoursLeft = start.timeIntervalSince(Date()) / 3600
                if hoursLeft >= 2 {
                    return .cancel
                } else {
                    return .tooLateToCancel
                }
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
        let start = DateFormatting.shared.parseISO8601(slot.startTime) ?? .distantFuture
        guard start <= Date() else {
            selectedSlot = slot
            showSessionNotStarted = true
            return
        }
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
        showSessionNotStarted = false
    }

    // MARK: - Private

    private func load() async {
        state = .loading
        let range = timeScope.dateRange()
        do {
            let response = try await service.fetchBookedByMe(from: range.from, to: range.to)
            allSlots = response.items
            state = .loaded
        } catch {
            state = .failed(.from(error))
        }
    }

    private func isBookedUpcoming(_ slot: MentorSlot) -> Bool {
        guard slot.status == .booked else { return false }
        let start = DateFormatting.shared.parseISO8601(slot.startTime) ?? .distantPast
        return start > Date()
    }

    private func isBookedToConfirm(_ slot: MentorSlot) -> Bool {
        guard slot.status == .booked else { return false }
        let start = DateFormatting.shared.parseISO8601(slot.startTime) ?? .distantFuture
        return start <= Date()
    }
}

// MARK: - MyBookingFilter

enum MyBookingFilter: String, CaseIterable, Sendable, Identifiable, ChipFilterOption {
    case upcoming
    case toConfirm
    case finished
    case rejected
    case reservationPending

    var id: String { rawValue }

    var label: String {
        switch self {
        case .upcoming: return ProfileStrings.bookingFilterUpcoming.localized
        case .toConfirm: return ProfileStrings.bookingFilterToConfirm.localized
        case .finished: return ProfileStrings.bookingFilterFinished.localized
        case .rejected: return ProfileStrings.statusRejected.localized
        case .reservationPending: return ProfileStrings.statusReservationPending.localized
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
