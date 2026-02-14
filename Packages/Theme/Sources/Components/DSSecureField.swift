//
//  DSSecureField.swift
//  Theme
//
//  Created by ShredMate on 14/02/2026.
//

import SwiftUI

/// iOS-native themed secure field — fully rounded pill shape, filled background,
/// show/hide toggle, optional title label above the field.
///
/// Accessibility:
/// - The toggle button has an explicit `accessibilityLabel`.
/// - Uses native `SecureField` / `TextField` so VoiceOver traits are correct.
public struct DSSecureField: View {

    @Environment(AppTheme.self) private var theme
    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

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
            inputField
            revealToggle
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

    @ViewBuilder
    private var inputField: some View {
        if isRevealed {
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .textContentType(.password)
        } else {
            SecureField(placeholder, text: $text)
                .focused($isFocused)
                .textContentType(.password)
        }
    }

    private var revealToggle: some View {
        Button {
            isRevealed.toggle()
        } label: {
            Image(systemName: isRevealed ? "eye.slash" : "eye")
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: Constants.Size.iconFrame)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
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
