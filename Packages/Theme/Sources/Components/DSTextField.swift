//
//  DSTextField.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// iOS-native themed text field — fully rounded pill shape, filled background,
/// no border. Optional title label displayed above the field.
///
/// Accessibility:
/// - Native `TextField` preserves VoiceOver label and traits.
/// - Subtle focus ring provides a visible indicator beyond color.
public struct DSTextField: View {

    @Environment(AppTheme.self) private var theme
    @FocusState private var isFocused: Bool

    private let title: String?
    private let placeholder: String
    private let icon: String?
    @Binding private var text: String

    public init(
        _ placeholder: String,
        text: Binding<String>,
        title: String? = nil,
        icon: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            titleLabel
            fieldRow
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var titleLabel: some View {
        if let title {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.colors.textSecondary)
        }
    }

    private var fieldRow: some View {
        HStack(spacing: theme.spacing.xs) {
            leadingIcon
            TextField(placeholder, text: $text)
                .focused($isFocused)
        }
        .padding(.horizontal, theme.spacing.md)
        .frame(minHeight: Constants.Size.fieldMinHeight)
        .background(fieldBackground)
        .clipShape(Capsule())
        .overlay(focusRing)
        .animation(.easeInOut(duration: Constants.Animation.focusDuration), value: isFocused)
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if let icon {
            Image(systemName: icon)
                .foregroundStyle(
                    isFocused ? theme.colors.primary : theme.colors.textTertiary
                )
                .frame(width: Constants.Size.iconFrame)
                .accessibilityHidden(true)
        }
    }

    private var fieldBackground: some View {
        Capsule()
            .fill(theme.colors.surfaceTertiary)
    }

    private var focusRing: some View {
        Capsule()
            .stroke(
                isFocused ? theme.colors.borderFocused : .clear,
                lineWidth: Constants.Size.focusBorderWidth
            )
    }
}
