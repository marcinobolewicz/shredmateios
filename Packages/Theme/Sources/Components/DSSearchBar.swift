//
//  DSSearchBar.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// Themed search bar with a magnifying glass icon and clear button.
///
/// Uses a filled background with no border, matching `DSTextField` aesthetics.
public struct DSSearchBar: View {

    @Environment(AppTheme.self) private var theme

    private let placeholder: String
    @Binding private var text: String

    public init(_ placeholder: String = "Search...", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                clearButton
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.xs + Constants.Spacing.xxs)
        .background(
            Capsule()
                .fill(theme.colors.surfaceTertiary)
        )
    }

    // MARK: - Subviews

    private var clearButton: some View {
        Button {
            text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(theme.colors.textTertiary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Clear search")
    }
}
