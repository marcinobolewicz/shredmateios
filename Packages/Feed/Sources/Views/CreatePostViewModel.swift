import Foundation
import Networking
import Common
import Places

@MainActor
@Observable
final class CreatePostViewModel {

    // MARK: - Form state

    var caption: String = ""
    var selectedPlace: Place?

    // MARK: - Submit state

    private(set) var isSubmitting = false
    var error: AppError?

    // MARK: - Constants

    let captionLimit = 300

    // MARK: - Computed

    var captionCount: Int { caption.count }
    var isOverLimit: Bool  { caption.count > captionLimit }

    var canSubmit: Bool {
        !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !isOverLimit
            && selectedPlace != nil
            && !isSubmitting
    }

    // MARK: - Dependencies

    private let feedService: any FeedServiceProtocol
    private let onSuccess: () -> Void

    // MARK: - Init

    init(feedService: any FeedServiceProtocol, onSuccess: @escaping () -> Void) {
        self.feedService = feedService
        self.onSuccess = onSuccess
    }

    // MARK: - Actions

    func submit() {
        guard canSubmit, let place = selectedPlace else { return }

        isSubmitting = true
        error = nil

        Task { [weak self] in
            guard let self else { return }
            defer { self.isSubmitting = false }

            let request = CreateActivityRequest(
                type: .checkIn,
                placeId: place.id.uuidString,
                caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
                taggedRiderIds: []
            )

            do {
                _ = try await feedService.createActivity(request)
                onSuccess()
            } catch {
                self.error = .from(error)
            }
        }
    }

    func dismissError() {
        error = nil
    }
}
