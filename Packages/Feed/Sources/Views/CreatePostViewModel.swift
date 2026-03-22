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
            && !isUploadingPhoto
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
        Task { await uploadPhoto(data) }
    }

    func removePhoto() {
        selectedPhotoData = nil
        uploadedPhotoUrl = nil
    }

    private func uploadPhoto(_ data: Data) async {
        isUploadingPhoto = true
        defer { isUploadingPhoto = false }
        do {
            let compressed = compressedForUpload(data) ?? data
            let response = try await feedService.uploadPhoto(imageData: compressed)
            uploadedPhotoUrl = response.photoUrl
        } catch {
            self.error = .from(error)
            selectedPhotoData = nil
        }
    }

    private func compressedForUpload(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maxSide: CGFloat = 1920
        let scale = min(maxSide / image.size.width, maxSide / image.size.height, 1)
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: targetSize)) }
        var quality: CGFloat = 0.85
        var output = resized.jpegData(compressionQuality: quality)
        while let d = output, d.count > 2_000_000, quality > 0.5 {
            quality -= 0.1
            output = resized.jpegData(compressionQuality: quality)
        }
        return output
    }

    // MARK: - Submit

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
                photoUrl: uploadedPhotoUrl,
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
