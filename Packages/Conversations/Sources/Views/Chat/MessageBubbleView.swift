//
//  MessageBubbleView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme
import Networking
import Common

struct MessageBubbleView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(ModerationService.self) private var moderation
    let viewData: MessageViewData

    @State private var resultMessage: String?

    var body: some View {
        HStack {
            if viewData.isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: viewData.isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                Text(viewData.text)
                    .dsTextStyle(
                        .body,
                        color: viewData.isFromCurrentUser ? \.primaryForeground : nil
                    )

                HStack(spacing: 4) {
                    Text(viewData.timeText)
                        .font(.caption2)
                        .foregroundStyle(
                            viewData.isFromCurrentUser
                                ? theme.colors.primaryForeground.opacity(0.7)
                                : theme.colors.textTertiary
                        )

                    if viewData.isFromCurrentUser {
                        Image(systemName: viewData.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption2)
                            .foregroundStyle(theme.colors.primaryForeground.opacity(0.85))
                    }
                }
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(bubbleBackground)
            .contextMenu {
                // Report is only offered for messages from the other person.
                if !viewData.isFromCurrentUser {
                    Button(role: .destructive) {
                        Task { await reportMessage() }
                    } label: {
                        Label(ConversationsStrings.reportMessageAction.localized, systemImage: "flag")
                    }
                }
            }

            if !viewData.isFromCurrentUser { Spacer(minLength: 60) }
        }
        .alert(
            resultMessage ?? "",
            isPresented: .init(get: { resultMessage != nil }, set: { if !$0 { resultMessage = nil } })
        ) {
            Button(CommonStrings.okButton.localized) { resultMessage = nil }
        }
    }

    private func reportMessage() async {
        do {
            try await moderation.report(targetType: .message, targetId: viewData.id, reason: .inappropriateContent)
            resultMessage = ConversationsStrings.reportMessageSuccess.localized
        } catch {
            resultMessage = ConversationsStrings.reportMessageFailed.localized
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
