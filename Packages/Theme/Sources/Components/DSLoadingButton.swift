//
//  DSLoadingButton.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Button that shows a `ProgressView` spinner while loading.
///
/// Works with any `ButtonStyle`. Convenience initializers are provided
/// for `DSPrimaryButtonStyle` and `DSSecondaryButtonStyle`.
///
/// Accessibility:
/// - The `accessibilityLabel` always matches `title`, even during loading,
///   so VoiceOver can identify the button regardless of its visual state.
public struct DSLoadingButton<Style: ButtonStyle>: View {

    private let title: String
    private let isLoading: Bool
    private let isDisabled: Bool
    private let style: Style
    private let action: () -> Void

    public init(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        style: Style,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    Text(title)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(style)
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? Constants.Opacity.disabled : 1)
        .accessibilityLabel(title)
    }
}

// MARK: - Primary Convenience

extension DSLoadingButton where Style == DSPrimaryButtonStyle {

    /// Creates a primary loading button.
    public init(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            title,
            isLoading: isLoading,
            isDisabled: isDisabled,
            style: .dsPrimary,
            action: action
        )
    }
}

// MARK: - Secondary Convenience

extension DSLoadingButton where Style == DSSecondaryButtonStyle {

    /// Creates a secondary loading button.
    public init(
        secondary title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            title,
            isLoading: isLoading,
            isDisabled: isDisabled,
            style: .dsSecondary,
            action: action
        )
    }
}
