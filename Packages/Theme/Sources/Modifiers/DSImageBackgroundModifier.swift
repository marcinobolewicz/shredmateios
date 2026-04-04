//
//  DSImageBackgroundModifier.swift
//  Theme
//

import SwiftUI

/// Fills the entire screen with an asset image, cropping to avoid white margins.
///
/// The image uses `scaledToFill` so narrower images are cropped on the sides
/// while taller images are cropped vertically. The content receives the screen's
/// safe-area dimensions as its layout reference — image aspect ratio and overflow
/// do not affect content positioning.
///
/// Usage:
/// ```swift
/// VStack {
///     Text("Welcome")
/// }
/// .dsImageBackground("onboarding_bg")
/// ```
private struct DSImageBackgroundModifier: ViewModifier {

    let assetName: String

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
    }
}

extension View {

    /// Applies a fullscreen asset image as background, cropping to fill without margins.
    public func dsImageBackground(_ assetName: String) -> some View {
        modifier(DSImageBackgroundModifier(assetName: assetName))
    }
}
