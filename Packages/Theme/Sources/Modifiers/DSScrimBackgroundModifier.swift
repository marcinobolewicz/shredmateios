//
//  DSScrimBackgroundModifier.swift
//  Theme
//

import SwiftUI

/// Fullscreen photo background with a vertical dark scrim for legibility.
///
/// Combines `dsImageBackground` with a top-to-bottom black gradient so that
/// foreground content (titles, frosted cards, white icons) reads cleanly on
/// arbitrary photographic backgrounds. Used by the welcome screen and the
/// auth flow to share one consistent treatment.
///
/// Usage:
/// ```swift
/// content
///     .dsScrimBackground("slide_1")
/// ```
private struct DSScrimBackgroundModifier: ViewModifier {

    let assetName: String

    func body(content: Content) -> some View {
        content
            .background {
                LinearGradient(
                    colors: [
                        .black.opacity(Self.topOpacity),
                        .black.opacity(Self.bottomOpacity)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .dsImageBackground(assetName)
    }

    private static let topOpacity: Double = 0.15
    private static let bottomOpacity: Double = 0.6
}

extension View {

    /// Applies a fullscreen photo background overlaid with a dark vertical scrim.
    public func dsScrimBackground(_ assetName: String) -> some View {
        modifier(DSScrimBackgroundModifier(assetName: assetName))
    }
}
