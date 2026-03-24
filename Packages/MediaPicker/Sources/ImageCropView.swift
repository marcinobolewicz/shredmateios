import SwiftUI

/// Full-screen image cropping view.
///
/// The image can be panned and pinch-zoomed; the crop frame stays fixed and centred.
/// The image is clamped so the crop frame is always covered (no empty corners).
///
/// - Parameters:
///   - image: The `UIImage` to crop.
///   - config: Aspect ratio, output size, and compression quality.
///   - onConfirm: Called with the crop rect in the image's **pixel** coordinate space.
///   - onCancel: Called when the user dismisses without confirming.
struct ImageCropView: View {

    let image: UIImage
    let config: ImageCropConfig
    let onConfirm: (CGRect) -> Void
    let onCancel: () -> Void

    // Active gesture deltas (reset to identity after each gesture ends).
    @GestureState private var dragDelta: CGSize = .zero
    @GestureState private var scaleDelta: CGFloat = 1.0

    // Committed (persisted) transform after each gesture ends.
    @State private var committedOffset: CGSize = .zero
    @State private var committedScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            let cropWin = cropWindowSize(in: geo.size)
            ZStack {
                Color.black.ignoresSafeArea()
                imageLayer(geo: geo, cropWin: cropWin)
                dimmingOverlay(cropWin: cropWin)
                cropBorder(cropWin: cropWin)
                cropGuideLines(cropWin: cropWin)
            }
            .onAppear { initScale(geo: geo, cropWin: cropWin) }
            .overlay(alignment: .topLeading) {
                cancelButton
                    .padding(.top, 56)
                    .padding(.leading, 20)
            }
            .overlay(alignment: .bottom) {
                confirmButton(geo: geo, cropWin: cropWin)
                    .padding(.bottom, 52)
                    .padding(.horizontal, 40)
            }
        }
        .ignoresSafeArea()
        .background(Color.black)
        .statusBarHidden()
    }

    // MARK: - Sub-views

    private func imageLayer(geo: GeometryProxy, cropWin: CGSize) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: geo.size.width)
            .scaleEffect(committedScale * scaleDelta)
            .offset(
                x: committedOffset.width + dragDelta.width,
                y: committedOffset.height + dragDelta.height
            )
            .gesture(combinedGesture(geo: geo, cropWin: cropWin))
    }

    private func dimmingOverlay(cropWin: CGSize) -> some View {
        CropOverlayShape(cropSize: cropWin)
            .fill(Color.black.opacity(0.55), style: FillStyle(eoFill: true))
            .allowsHitTesting(false)
    }

    private func cropBorder(cropWin: CGSize) -> some View {
        Rectangle()
            .strokeBorder(.white, lineWidth: 1)
            .frame(width: cropWin.width, height: cropWin.height)
            .allowsHitTesting(false)
    }

    /// Subtle rule-of-thirds guide lines inside the crop frame.
    private func cropGuideLines(cropWin: CGSize) -> some View {
        Canvas { ctx, size in
            let thirdW = size.width  / 3
            let thirdH = size.height / 3
            let shading = GraphicsContext.Shading.color(.white.opacity(0.35))
            let strokeStyle = StrokeStyle(lineWidth: 0.5)

            for col in 1...2 {
                var path = Path()
                path.move(to: CGPoint(x: thirdW * CGFloat(col), y: 0))
                path.addLine(to: CGPoint(x: thirdW * CGFloat(col), y: size.height))
                ctx.stroke(path, with: shading, style: strokeStyle)
            }
            for row in 1...2 {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: thirdH * CGFloat(row)))
                path.addLine(to: CGPoint(x: size.width, y: thirdH * CGFloat(row)))
                ctx.stroke(path, with: shading, style: strokeStyle)
            }
        }
        .frame(width: cropWin.width, height: cropWin.height)
        .allowsHitTesting(false)
    }

    private var cancelButton: some View {
        Button(action: onCancel) {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.black.opacity(0.45))
                .clipShape(Circle())
        }
    }

    private func confirmButton(geo: GeometryProxy, cropWin: CGSize) -> some View {
        Button {
            let rect = computeCropRectInImagePixels(geo: geo, cropWin: cropWin)
            onConfirm(rect)
        } label: {
            Text("Use Photo")
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Geometry helpers

    /// The size of the crop frame, derived from `config.aspectRatio` and the container width.
    private func cropWindowSize(in containerSize: CGSize) -> CGSize {
        let width = containerSize.width - 48       // 24 pt inset each side
        let height = width / config.aspectRatio
        // Ensure the crop window fits vertically (e.g. very tall aspect ratios).
        let maxHeight = containerSize.height - 200 // leave room for buttons
        let clampedHeight = min(height, maxHeight)
        let clampedWidth = clampedHeight * config.aspectRatio
        return CGSize(width: clampedWidth, height: clampedHeight)
    }

    /// Sets initial scale so the image just covers the crop frame.
    private func initScale(geo: GeometryProxy, cropWin: CGSize) {
        let (displayedW, displayedH) = displayedImageSize(geo: geo)
        let minScaleX = cropWin.width  / displayedW
        let minScaleY = cropWin.height / displayedH
        committedScale = max(minScaleX, minScaleY, 1)
    }

    private func minScale(geo: GeometryProxy, cropWin: CGSize) -> CGFloat {
        let (displayedW, displayedH) = displayedImageSize(geo: geo)
        return max(cropWin.width / displayedW, cropWin.height / displayedH)
    }

    /// The size of the image as rendered by `.scaledToFit` into `geo.size.width`.
    private func displayedImageSize(geo: GeometryProxy) -> (CGFloat, CGFloat) {
        let displayedW = geo.size.width
        let displayedH = displayedW * image.size.height / image.size.width
        return (displayedW, displayedH)
    }

    // MARK: - Gestures

    private func combinedGesture(geo: GeometryProxy, cropWin: CGSize) -> some Gesture {
        let drag = DragGesture()
            .updating($dragDelta) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let proposed = CGSize(
                    width:  committedOffset.width  + value.translation.width,
                    height: committedOffset.height + value.translation.height
                )
                committedOffset = clampedOffset(proposed, scale: committedScale, geo: geo, cropWin: cropWin)
            }

        let magnify = MagnifyGesture()
            .updating($scaleDelta) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                let floor = minScale(geo: geo, cropWin: cropWin)
                let newScale = min(8.0, max(floor, committedScale * value.magnification))
                committedScale = newScale
                committedOffset = clampedOffset(committedOffset, scale: newScale, geo: geo, cropWin: cropWin)
            }

        return drag.simultaneously(with: magnify)
    }

    /// Clamps `offset` so the image always covers the crop window (no empty corners).
    private func clampedOffset(_ offset: CGSize, scale: CGFloat, geo: GeometryProxy, cropWin: CGSize) -> CGSize {
        let (displayedW, displayedH) = displayedImageSize(geo: geo)
        let scaledW = displayedW * scale
        let scaledH = displayedH * scale
        let maxX = max(0, (scaledW - cropWin.width)  / 2)
        let maxY = max(0, (scaledH - cropWin.height) / 2)
        return CGSize(
            width:  min(maxX,  max(-maxX,  offset.width)),
            height: min(maxY,  max(-maxY,  offset.height))
        )
    }

    // MARK: - Crop rect calculation

    /// Maps the (fixed, centred) crop frame back into the image's pixel coordinate space.
    ///
    /// The image is rendered centre-anchored inside the GeometryReader at its native
    /// display scale, then the user's committed transform (scale + offset) is applied.
    ///
    ///     screenPt = imageCenter_inView + (pixelPt - imagePixelCenter) * totalDisplayScale
    ///     ⟹  pixelPt = imagePixelCenter + (screenPt - imageCenter_inView) / totalDisplayScale
    private func computeCropRectInImagePixels(geo: GeometryProxy, cropWin: CGSize) -> CGRect {
        // Points-per-pixel scale of the base (unzoomed) display.
        let baseScale = geo.size.width / image.size.width
        let totalScale = baseScale * committedScale

        // Where the image's visual centre sits in the view's coordinate space.
        let imageCenterInView = CGPoint(
            x: geo.size.width  / 2 + committedOffset.width,
            y: geo.size.height / 2 + committedOffset.height
        )

        // Top-left corner of the crop frame in the view's coordinate space.
        let cropOriginInView = CGPoint(
            x: geo.size.width  / 2 - cropWin.width  / 2,
            y: geo.size.height / 2 - cropWin.height / 2
        )

        let imagePixelCenter = CGPoint(x: image.size.width / 2, y: image.size.height / 2)

        let cropOriginInPixels = CGPoint(
            x: imagePixelCenter.x + (cropOriginInView.x - imageCenterInView.x) / totalScale,
            y: imagePixelCenter.y + (cropOriginInView.y - imageCenterInView.y) / totalScale
        )
        let cropSizeInPixels = CGSize(
            width:  cropWin.width  / totalScale,
            height: cropWin.height / totalScale
        )

        return CGRect(origin: cropOriginInPixels, size: cropSizeInPixels)
    }
}


