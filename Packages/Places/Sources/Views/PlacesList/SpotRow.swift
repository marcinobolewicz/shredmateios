//
//  SpotRow.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Theme
import Common

// MARK: - SpotRow

struct SpotRow: View {
    @Environment(AppTheme.self) private var theme
    let viewData: SpotRowViewData

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            avatar

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(viewData.title)
                        .dsTextStyle(.heading)
                        .lineLimit(1)
                    Spacer()
                }

                if !viewData.description.isEmpty {
                    Text(viewData.description)
                        .dsTextStyle(.subheadline)
                        .lineLimit(1)
                }

                PlaceTagsRow(tags: viewData.placeTags)

                HStack(spacing: theme.spacing.sm) {
                    StatText(label: PlacesStrings.ridersLabel.localized, value: viewData.ridersCount)
                    StatText(label: PlacesStrings.mentorsLabel.localized, value: viewData.mentorsCount)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        AvatarView(avatar: viewData.avatar, size: 44)
    }
}

// MARK: - Supporting Views

private struct StatText: View {
    @Environment(AppTheme.self) private var theme
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: theme.spacing.xxs + 2) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
            Text("\(value)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
        }
    }
}

