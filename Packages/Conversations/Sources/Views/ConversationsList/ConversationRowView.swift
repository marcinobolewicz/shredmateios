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

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            avatar
            
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                HStack {
                    Text(viewData.participantName)
                        .dsTextStyle(.heading)
                        .lineLimit(1)

                    Spacer()

                    Text(viewData.dateText)
                        .dsTextStyle(.caption)
                }

                HStack {
                    Text(viewData.lastMessage)
                        .dsTextStyle(.subheadline)
                        .lineLimit(1)

                    Spacer()

                    if viewData.unreadCount > 0 {
                        unreadBadge
                    }
                }
            }
        }
        .padding(.vertical, theme.spacing.xs)
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        AvatarView(url: viewData.avatarURL, initials: viewData.avatarInitials)
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
