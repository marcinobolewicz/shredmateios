import SwiftUI

extension View {

    /// Presents a native photo picker followed by an interactive crop view.
    ///
    /// When the user confirms a crop, `onResult` is called with the JPEG `Data`
    /// encoded at `config.targetSize` (default 960×960). The sheet dismisses itself
    /// automatically after calling `onResult`.
    ///
    /// ```swift
    /// .imageCropPicker(isPresented: $showPicker) { result in
    ///     if case .success(let data) = result {
    ///         viewModel.uploadPhoto(data)
    ///     }
    /// }
    ///
    /// // Custom aspect ratio / output size:
    /// .imageCropPicker(isPresented: $showPicker, config: .landscape43) { result in ... }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: Controls sheet presentation. Set to `false` to dismiss programmatically.
    ///   - config: Crop proportions and output settings. Defaults to `.square` (1:1, 960×960).
    ///   - onResult: Called on the main actor with `.success(Data)` or `.failure(ImageCropError)`.
    public func imageCropPicker(
        isPresented: Binding<Bool>,
        config: ImageCropConfig = .square,
        onResult: @escaping (Result<Data, any Error>) -> Void
    ) -> some View {
        sheet(isPresented: isPresented) {
            ImageCropPickerSheet(
                config: config,
                onResult: onResult,
                onDismiss: { isPresented.wrappedValue = false }
            )
        }
    }
}
