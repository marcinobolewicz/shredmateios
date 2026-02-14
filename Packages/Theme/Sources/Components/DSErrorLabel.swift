//
//  DSErrorLabel.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Inline error message with an icon, styled with the theme's error color.
///
/// Accessibility: children are combined into a single element for VoiceOver.
public struct DSErrorLabel: View {

    @Environment(AppTheme.self) private var theme

    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        HStack(spacing: Constants.Spacing.xxs + 2) {
            Image(systemName: "exclamationmark.circle.fill")
            Text(message)
        }
        .font(.caption)
        .foregroundStyle(theme.colors.error)
        .accessibilityElement(children: .combine)
    }
}
