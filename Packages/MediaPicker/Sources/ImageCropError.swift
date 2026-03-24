/// Errors produced by the MediaPicker module.
public enum ImageCropError: Error, Sendable {
    /// The selected photo data could not be loaded or decoded.
    case imageLoadFailed
    /// The crop + resize step produced no output (e.g. degenerate crop rect).
    case processingFailed
}
