import Foundation
import UIKit
import Networking
import Common
import Places

@MainActor
@Observable
final class CreatePostViewModel {

    // MARK: - Form state

    var caption: String = ""
    var selectedPlace: Place?
    var selectedPhotoData: Data?

    // MARK: - Upload / submit state

    private(set) var isUploadingPhoto = false
    private(set) var isSubmitting = false
    private(set) var uploadedPhotoUrl: String?
    var error: AppError?

    // MARK: - Constants

    let captionLimit = 300

    // MARK: - Computed

    var captionCount: Int { caption.count }
    var isOverLimit: Bool  { caption.count > captionLimit }
    var hasPhoto: Bool { selectedPhotoData != nil }

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

    // MARK: - Photo

    func photoSelected(_ data: Data) {
        selectedPhotoData = data
        uploadedPhotoUrl = nil
    }

    func removePhoto() {
        selectedPhotoData = nil
        uploadedPhotoUrl = nil
    }

    private func uploadPhoto(_ data: Data) async {
        isUploadingPhoto = true
        defer { isUploadingPhoto = false }
        do {
            let response = try await feedService.uploadPhoto(imageData: data)
            uploadedPhotoUrl = response.photoUrl
        } catch {
            self.error = .from(error)
            selectedPhotoData = nil
        }
    }

    // compressedForUpload removed — MediaPicker (ImageCropProcessor) already
    // delivers ≤900 KB JPEG at 960 × 960 px with scale = 1 before upload.

    // MARK: - Submit

    func submit() {
        guard canSubmit, let place = selectedPlace else { return }

        isSubmitting = true
        error = nil

        Task { [weak self] in
            guard let self else { return }
            defer { self.isSubmitting = false }

            do {
                if let photoData = selectedPhotoData, uploadedPhotoUrl == nil {
                    await uploadPhoto(photoData)
                    if self.error != nil { return }
                }

                let request = CreateActivityRequest(
                    type: .checkIn,
                    placeId: place.id.uuidString,
                    photoUrl: uploadedPhotoUrl,
                    caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
                    taggedRiderIds: []
                )

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
