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
    var showRejectConfirmation = false
    var showSessionNotStarted = false

    static let rejectWindowSeconds: TimeInterval = 30 * 60

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
            let now = Date()
            let start = DateFormatting.shared.parseISO8601(slot.startTime) ?? .distantPast
            if start > now {
                let hoursLeft = start.timeIntervalSince(now) / 3600
                return hoursLeft >= 2 ? .cancel : .tooLateToCancel
            } else {
                let end = DateFormatting.shared.parseISO8601(slot.endTime) ?? .distantFuture
                return .complete(canReject: Self.canReject(now: now, startTime: start, endTime: end))
            }
        case .completed:
            return .completed(slot.recommendationStatus)
        default:
            return nil
        }
    }

    static func canReject(now: Date, startTime: Date, endTime: Date) -> Bool {
        startTime <= now && now <= endTime.addingTimeInterval(rejectWindowSeconds)
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

    func rejectTapped(_ slot: MentorSlot) {
        selectedSlot = slot
        showRejectConfirmation = true
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

    func confirmReject() async {
        guard let slot = selectedSlot else { return }
        do {
            _ = try await service.rejectSession(id: slot.id)
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
        showRejectConfirmation = false
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
    case complete(canReject: Bool)
    case completed(MentorSlotRecommendationStatus?)
}
