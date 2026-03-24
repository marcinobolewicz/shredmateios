import SwiftUI

/// A `Shape` that fills its entire bounding rectangle except for a centred cutout.
///
/// Use with `FillStyle(eoFill: true)` to punch a transparent hole in a solid colour:
/// ```swift
/// CropOverlayShape(cropSize: cropWin)
///     .fill(.black.opacity(0.55), style: FillStyle(eoFill: true))
/// ```
struct CropOverlayShape: Shape {

    let cropSize: CGSize

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Outer rectangle — filled by the colour.
        path.addRect(rect)
        // Inner rectangle — subtracted via even-odd rule, leaving a transparent window.
        let cropRect = CGRect(
            x: (rect.width  - cropSize.width)  / 2,
            y: (rect.height - cropSize.height) / 2,
            width:  cropSize.width,
            height: cropSize.height
        )
        path.addRect(cropRect)
        return path
    }
}
