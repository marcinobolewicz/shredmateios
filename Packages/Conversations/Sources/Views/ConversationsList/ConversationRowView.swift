//
//  ConversationRowView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme
import Common

struct ConversationRowView: View {
    @Environment(AppTheme.self) private var theme
    let viewData: ConversationRowViewData

    private enum Layout {
        static let avatarSize: CGFloat = 56
        static let chevronSize: CGFloat = 32
    }

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            avatar

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(viewData.participantName)
                    .dsTextStyle(.body)
                    .lineLimit(1)

                HStack {
                    Text(viewData.lastMessage)
                        .dsTextStyle(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)

                    if viewData.unreadCount > 0 {
                        unreadBadge
                    }
                }

                HStack {
                    Spacer()

                    Text(viewData.dateText)
                        .dsTextStyle(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.trailing, Layout.chevronSize + theme.spacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .trailing) {
            ChevronCircleView()
        }
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        AvatarView(url: viewData.avatarURL, initials: viewData.avatarInitials, size: Layout.avatarSize)
    }

    private var unreadBadge: some View {
        Text("\(viewData.unreadCount)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(theme.colors.primaryForeground)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(theme.colors.primary)
            )
    }
}
