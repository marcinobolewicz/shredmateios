import UIKit

/// Crops a region of a `UIImage` and resizes it to a target size, then JPEG-encodes the result.
///
/// Stateless and `Sendable` — safe to call from any isolation context.
struct ImageCropProcessor: Sendable {

    private let minimumCompressionQuality: CGFloat = 0.5
    private let compressionStep: CGFloat = 0.08

    /// Returns JPEG data for the cropped and resized image, or `nil` on failure.
    ///
    /// Quality is reduced iteratively (by `compressionStep` per pass) until
    /// the result fits within `maxBytes`, down to a floor of 0.5.
    ///
    /// - Parameters:
    ///   - image: Source image. EXIF orientation is normalised automatically.
    ///   - cropRect: Region to extract, in the image's **pixel** coordinate space.
    ///               The rect is clamped to the image bounds before cropping.
    ///   - targetSize: Output pixel dimensions.
    ///   - compressionQuality: Initial JPEG quality in [0, 1].
    ///   - maxBytes: Maximum allowed output size in bytes.
    func process(
        image: UIImage,
        cropRect: CGRect,
        targetSize: CGSize,
        compressionQuality: CGFloat,
        maxBytes: Int
    ) -> Data? {
        let normalized = normalizedOrientation(image)
        guard let cropped = crop(normalized, rect: cropRect) else { return nil }
        let resized = resize(cropped, to: targetSize)
        return compressedJPEGData(from: resized, quality: compressionQuality, maxBytes: maxBytes)
    }

    // MARK: - Private

    private func normalizedOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    private func crop(_ image: UIImage, rect: CGRect) -> UIImage? {
        let clamped = rect.intersection(CGRect(origin: .zero, size: image.size))
        guard !clamped.isEmpty, let cgImage = image.cgImage?.cropping(to: clamped) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private func resize(_ image: UIImage, to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private func compressedJPEGData(from image: UIImage, quality: CGFloat, maxBytes: Int) -> Data? {
        var currentQuality = quality
        var output = image.jpegData(compressionQuality: currentQuality)

        while let data = output,
              data.count > maxBytes,
              currentQuality > minimumCompressionQuality {
            currentQuality -= compressionStep
            output = image.jpegData(compressionQuality: currentQuality)
        }

        return output
    }
}
