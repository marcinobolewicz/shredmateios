import SwiftUI

/// The sheet content that orchestrates the full pick → crop → output flow.
///
/// State machine:
/// ```
/// .picking  ──(photo selected)──▶  .cropping(UIImage)
///     ▲                                    │
///     └──────────── (cancel crop) ─────────┘
///
/// .picking  ──(user cancels picker)──▶  onDismiss()
/// .cropping ──(confirm)             ──▶  onResult(.success) → onDismiss()
/// .cropping ──(processing failed)   ──▶  onResult(.failure) → onDismiss()
/// ```
struct ImageCropPickerSheet: View {

    let config: ImageCropConfig
    let onResult: (Result<Data, any Error>) -> Void
    let onDismiss: () -> Void

    @State private var step: Step = .picking

    private let processor = ImageCropProcessor()

    var body: some View {
        Group {
            switch step {
            case .picking:
                ImagePhotoLibraryPicker { image in
                    guard let image else {
                        onDismiss()
                        return
                    }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        step = .cropping(image)
                    }
                }
                .transition(.asymmetric(insertion: .identity, removal: .opacity))

            case .cropping(let image):
                ImageCropView(image: image, config: config) { cropRect in
                    finalize(image: image, cropRect: cropRect)
                } onCancel: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        step = .picking
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
            }
        }
    }

    // MARK: - Private

    private func finalize(image: UIImage, cropRect: CGRect) {
        if let data = processor.process(
            image: image,
            cropRect: cropRect,
            targetSize: config.targetSize,
            compressionQuality: config.compressionQuality,
            maxBytes: config.maxBytes
        ) {
            onResult(.success(data))
        } else {
            onResult(.failure(ImageCropError.processingFailed))
        }
        onDismiss()
    }

    // MARK: - Step

    private enum Step {
        case picking
        case cropping(UIImage)
    }
}
