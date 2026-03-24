import CoreGraphics

/// Configuration for the image crop picker.
public struct ImageCropConfig: Sendable {

    /// Width-to-height ratio of the crop region. Default is `1` (square).
    public let aspectRatio: CGFloat

    /// Pixel dimensions of the final output image. Default is `960×960`.
    public let targetSize: CGSize

    /// Maximum output file size in bytes.
    /// The processor iteratively reduces JPEG quality until the result fits.
    /// Default is `900_000` (≈879 KB).
    public let maxBytes: Int

    /// Initial JPEG compression quality in [0, 1]. Default is `0.86`.
    public let compressionQuality: CGFloat

    public init(
        aspectRatio: CGFloat = 1,
        targetSize: CGSize = CGSize(width: 960, height: 960),
        maxBytes: Int = 900_000,
        compressionQuality: CGFloat = 0.86
    ) {
        self.aspectRatio = aspectRatio
        self.targetSize = targetSize
        self.maxBytes = maxBytes
        self.compressionQuality = compressionQuality
    }

    /// 1:1 square crop, 960×960 px, max 900 KB. The default for post/avatar photos.
    public static let square = ImageCropConfig()

    /// 4:3 landscape crop, 960×720 px, max 900 KB.
    public static let landscape43 = ImageCropConfig(
        aspectRatio: 4.0 / 3.0,
        targetSize: CGSize(width: 960, height: 720)
    )

    /// 16:9 landscape crop, 960×540 px, max 900 KB.
    public static let widescreen = ImageCropConfig(
        aspectRatio: 16.0 / 9.0,
        targetSize: CGSize(width: 960, height: 540)
    )
}
