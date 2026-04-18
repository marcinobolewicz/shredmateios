import Foundation
import Networking
import Common
import Payment
import StripePaymentSheet

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

    // Payment flow state
    private(set) var isProcessingPayment = false
    var showPaymentSheet = false
    var paymentSheet: PaymentSheet?
    var showPaymentSuccess = false
    var showPaymentError = false
    var paymentErrorMessage: String?
    private var currentPaymentIntentId: String?
    private var currentPaymentSlotId: String?

    let isOwner: Bool

    private let mentorRiderId: String
    private let service: MentorSlotsServiceProtocol
    private let stripePaymentService: StripePaymentService?
    private let presenter = MentorSlotPresenter()

    init(
        mentorRiderId: String,
        currentRiderId: String?,
        service: MentorSlotsServiceProtocol,
        stripePaymentService: StripePaymentService? = nil
    ) {
        self.mentorRiderId = mentorRiderId
        self.isOwner = currentRiderId != nil && currentRiderId == mentorRiderId
        self.service = service
        self.stripePaymentService = stripePaymentService
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

    // MARK: - Payment Flow

    func confirmBook() async {
        guard let slot = selectedSlot else { return }
        guard let stripePaymentService else {
            actionError = "Payment service unavailable"
            selectedSlot = nil
            return
        }

        actionError = nil
        isProcessingPayment = true

        do {
            let response = try await service.createPaymentIntent(slotId: slot.id)
            currentPaymentIntentId = response.paymentIntentId
            currentPaymentSlotId = slot.id
            paymentSheet = stripePaymentService.makePaymentSheet(clientSecret: response.clientSecret)
            isProcessingPayment = false
            showPaymentSheet = true
        } catch {
            isProcessingPayment = false
            actionError = error.localizedDescription
        }
    }

    func handlePaymentResult(_ result: PaymentResult) {
        switch result {
        case .completed:
            Task { await confirmPaymentOnBackend() }
        case .canceled:
            resetPaymentState()
        case .failed(let message):
            paymentErrorMessage = message
            showPaymentError = true
            resetPaymentState()
        }
    }

    private func confirmPaymentOnBackend() async {
        guard let slotId = currentPaymentSlotId,
              let paymentIntentId = currentPaymentIntentId else { return }

        isProcessingPayment = true

        do {
            _ = try await service.confirmPayment(slotId: slotId, paymentIntentId: paymentIntentId)
            isProcessingPayment = false
            resetPaymentState()
            showPaymentSuccess = true
            await loadSlots()
        } catch {
            isProcessingPayment = false
            resetPaymentState()
            actionError = error.localizedDescription
        }
    }

    private func resetPaymentState() {
        currentPaymentIntentId = nil
        currentPaymentSlotId = nil
        paymentSheet = nil
        selectedSlot = nil
    }

    func dismissAction() {
        selectedSlot = nil
        showDeleteConfirmation = false
        showBookConfirmation = false
        showBookingTooSoon = false
    }

    func dismissPaymentError() {
        paymentErrorMessage = nil
        showPaymentError = false
    }

    func dismissPaymentSuccess() {
        showPaymentSuccess = false
    }
}
