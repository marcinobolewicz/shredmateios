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
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            AvatarView(avatar: viewData.avatar, initials: viewData.initials, size: 56)
                .fixedSize()

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(viewData.title)
                    .dsTextStyle(.heading)
                    .lineLimit(1)

                if !viewData.description.isEmpty {
                    Text(viewData.description)
                        .dsTextStyle(.subheadline)
                        .lineLimit(1)
                        .padding(.trailing, 36)
                }

                tagsRow

                HStack(spacing: theme.spacing.sm) {
                    StatText(label: PlacesStrings.ridersLabel.localized, value: viewData.ridersCount)
                    StatText(label: PlacesStrings.mentorsLabel.localized, value: viewData.mentorsCount)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .trailing) {
            chevronCircle
        }
        .padding(.vertical, theme.spacing.sm)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var tagsRow: some View {
        if !viewData.placeTags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(Array(viewData.placeTags.enumerated()), id: \.offset) { index, tag in
                        PlaceTagPill(text: tag, index: index)
                    }
                }
            }
        }
    }

    private var chevronCircle: some View {
        ZStack {
            Circle()
                .fill(theme.colors.background)
                .frame(width: 32, height: 32)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 1)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
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
