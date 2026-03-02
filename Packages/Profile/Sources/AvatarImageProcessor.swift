import Foundation
import UIKit

struct AvatarImageProcessingConfig: Sendable {
    let targetSize: CGSize
    let maxBytes: Int
    let initialCompressionQuality: CGFloat
    let minimumCompressionQuality: CGFloat
    let compressionStep: CGFloat

    static let `default` = AvatarImageProcessingConfig(
        targetSize: CGSize(width: 1024, height: 1024),
        maxBytes: 900_000,
        initialCompressionQuality: 0.86,
        minimumCompressionQuality: 0.5,
        compressionStep: 0.08
    )
}

struct AvatarImageProcessor: Sendable {
    private let config: AvatarImageProcessingConfig

    init(config: AvatarImageProcessingConfig = .default) {
        self.config = config
    }

    func process(_ data: Data) -> Data? {
        guard let sourceImage = UIImage(data: data) else {
            return nil
        }

        let normalized = normalizeOrientation(sourceImage)
        let rendered = cropAndResizeToSquare(normalized, targetSize: config.targetSize)
        return compressedJPEGData(from: rendered)
    }

    private func normalizeOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1

        return UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private func cropAndResizeToSquare(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let width = image.size.width
        let height = image.size.height
        let side = min(width, height)

        let cropRect = CGRect(
            x: (width - side) / 2,
            y: (height - side) / 2,
            width: side,
            height: side
        )

        let scale = targetSize.width / cropRect.width
        let drawRect = CGRect(
            x: -cropRect.origin.x * scale,
            y: -cropRect.origin.y * scale,
            width: width * scale,
            height: height * scale
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            image.draw(in: drawRect)
        }
    }

    private func compressedJPEGData(from image: UIImage) -> Data? {
        var quality = config.initialCompressionQuality
        var output = image.jpegData(compressionQuality: quality)

        while let data = output,
              data.count > config.maxBytes,
              quality > config.minimumCompressionQuality {
            quality -= config.compressionStep
            output = image.jpegData(compressionQuality: quality)
        }

        return output
    }
}
