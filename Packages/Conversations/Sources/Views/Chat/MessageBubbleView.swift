//
//  MessageBubbleView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme

struct MessageBubbleView: View {
    @Environment(AppTheme.self) private var theme
    let viewData: MessageViewData

    var body: some View {
        HStack {
            if viewData.isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: viewData.isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                Text(viewData.text)
                    .dsTextStyle(.body)
                    .foregroundStyle(
                        viewData.isFromCurrentUser
                            ? theme.colors.primaryForeground
                            : theme.colors.textPrimary
                    )

                Text(viewData.timeText)
                    .font(.caption2)
                    .foregroundStyle(
                        viewData.isFromCurrentUser
                            ? theme.colors.primaryForeground.opacity(0.7)
                            : theme.colors.textTertiary
                    )
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(bubbleBackground)

            if !viewData.isFromCurrentUser { Spacer(minLength: 60) }
        }
    }

    private var bubbleBackground: some View {
        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
            .fill(
                viewData.isFromCurrentUser
                    ? theme.colors.primary
                    : theme.colors.surfaceTertiary
            )
    }
}
