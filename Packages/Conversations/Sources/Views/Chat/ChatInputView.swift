//
//  ChatInputView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme
import Common

struct ChatInputView: View {
    @Environment(AppTheme.self) private var theme
    @Binding var text: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            TextField(ConversationsStrings.chatInputPlaceholder.localized, text: $text, axis: .vertical)
                .lineLimit(1...5)
                .foregroundStyle(theme.colors.textPrimary)
                .tint(theme.colors.primary)
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                        .fill(theme.colors.surfaceTertiary)
                )

            Button(action: onSend) {
                Text(CommonStrings.sendButton.localized)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(theme.colors.primaryForeground)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .background(
                        Capsule().fill(
                            sendButtonDisabled
                                ? theme.colors.primary.opacity(0.5)
                                : theme.colors.primary
                        )
                    )
            }
            .disabled(sendButtonDisabled)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.xs)
        .background(
            theme.colors.surface
                .shadow(color: .black.opacity(0.1), radius: 4, y: -2)
        )
    }

    private var sendButtonDisabled: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
