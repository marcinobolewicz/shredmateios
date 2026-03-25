import XCTest
import UIKit
@testable import MediaPicker

final class ImageCropProcessorTests: XCTestCase {

    private let processor = ImageCropProcessor()
    private let maxBytes = 900_000

    // MARK: - Output dimensions

    func testOutputMatchesTargetSize() {
        let image = makeImage(width: 800, height: 800)
        let cropRect = CGRect(x: 0, y: 0, width: 800, height: 800)
        let target = CGSize(width: 960, height: 960)

        let data = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 0.86, maxBytes: maxBytes)

        XCTAssertNotNil(data)
        let output = data.flatMap(UIImage.init(data:))
        XCTAssertEqual(output?.size.width,  target.width)
        XCTAssertEqual(output?.size.height, target.height)
    }

    func testNonSquareTargetSize() {
        let image = makeImage(width: 1200, height: 900)
        let cropRect = CGRect(x: 0, y: 0, width: 1200, height: 900)
        let target = CGSize(width: 960, height: 720)

        let data = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 0.86, maxBytes: maxBytes)

        XCTAssertNotNil(data)
        let output = data.flatMap(UIImage.init(data:))
        XCTAssertEqual(output?.size.width,  target.width)
        XCTAssertEqual(output?.size.height, target.height)
    }

    // MARK: - Crop rect clamping

    func testCropRectClampedWhenPartiallyOutOfBounds() {
        let image = makeImage(width: 400, height: 400)
        let cropRect = CGRect(x: -50, y: -50, width: 500, height: 500)
        let target = CGSize(width: 960, height: 960)

        let data = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 0.86, maxBytes: maxBytes)
        // Clamped to (0,0,400,400) → valid crop.
        XCTAssertNotNil(data)
    }

    func testCropRectCompletelyOutsideImageReturnsNil() {
        let image = makeImage(width: 400, height: 400)
        let cropRect = CGRect(x: 500, y: 500, width: 200, height: 200) // no overlap
        let target = CGSize(width: 960, height: 960)

        let data = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 0.86, maxBytes: maxBytes)
        XCTAssertNil(data)
    }

    // MARK: - Orientation normalisation

    func testLandscapeImageProducesData() {
        let image = makeImage(width: 1200, height: 800)
        let cropRect = CGRect(x: 200, y: 0, width: 800, height: 800)
        let target = CGSize(width: 960, height: 960)

        let data = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 0.86, maxBytes: maxBytes)
        XCTAssertNotNil(data)
    }

    func testPortraitImageProducesData() {
        let image = makeImage(width: 600, height: 900)
        let cropRect = CGRect(x: 0, y: 150, width: 600, height: 600)
        let target = CGSize(width: 960, height: 960)

        let data = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 0.86, maxBytes: maxBytes)
        XCTAssertNotNil(data)
    }

    // MARK: - Max bytes cap

    func testOutputNeverExceedsMaxBytes() {
        let image = makeImage(width: 800, height: 800)
        let cropRect = CGRect(x: 0, y: 0, width: 800, height: 800)
        let target = CGSize(width: 960, height: 960)
        let cap = 300_000

        let data = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 0.86, maxBytes: cap)
        XCTAssertNotNil(data)
        XCTAssertLessThanOrEqual(data!.count, cap)
    }

    // MARK: - Compression quality

    func testHigherQualityProducesLargerFile() {
        let image = makeImage(width: 800, height: 800)
        let cropRect = CGRect(x: 0, y: 0, width: 800, height: 800)
        let target = CGSize(width: 960, height: 960)
        let bigCap = 10_000_000 // disable byte cap for this comparison

        let hi = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 1.0, maxBytes: bigCap)
        let lo = processor.process(image: image, cropRect: cropRect, targetSize: target, compressionQuality: 0.1, maxBytes: bigCap)

        XCTAssertNotNil(hi)
        XCTAssertNotNil(lo)
        XCTAssertGreaterThan(hi!.count, lo!.count)
    }

    // MARK: - Helpers

    private func makeImage(width: Int, height: Int, color: UIColor = .systemBlue) -> UIImage {
        let size = CGSize(width: width, height: height)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
