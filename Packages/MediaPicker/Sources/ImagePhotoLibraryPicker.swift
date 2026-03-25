import PhotosUI
import SwiftUI

/// Embeds a `PHPickerViewController` directly inside a SwiftUI view hierarchy.
///
/// The picker does **not** dismiss itself after selection — SwiftUI manages the
/// view's lifetime. The caller is responsible for transitioning away when
/// `onPick` is called.
struct ImagePhotoLibraryPicker: UIViewControllerRepresentable {

    /// Called on the main actor with the loaded image, or `nil` when the user cancels.
    let onPick: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    // MARK: - Coordinator

    @MainActor
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {

        private let onPick: (UIImage?) -> Void

        init(onPick: @escaping (UIImage?) -> Void) {
            self.onPick = onPick
        }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            guard let result = results.first else {
                onPick(nil)
                return
            }
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                onPick(nil)
                return
            }
            Task { @MainActor [weak self] in
                let image: UIImage? = await withCheckedContinuation { continuation in
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        continuation.resume(returning: object as? UIImage)
                    }
                }
                self?.onPick(image)
            }
        }
    }
}
