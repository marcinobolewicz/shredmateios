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

    private enum Layout {
        static let avatarSize: CGFloat = 56
        static let chevronSize: CGFloat = 32
        static let chevronIconSize: CGFloat = 11
    }

    var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            AvatarView(avatar: viewData.avatar, initials: viewData.initials, size: Layout.avatarSize)
                .fixedSize()

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(viewData.title)
                    .dsTextStyle(.heading)
                    .lineLimit(1)

                if !viewData.description.isEmpty {
                    Text(viewData.description)
                        .dsTextStyle(.subheadline)
                        .lineLimit(1)
                        .padding(.trailing, Layout.chevronSize + Constants.Spacing.xxs)
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
                .frame(width: Layout.chevronSize, height: Layout.chevronSize)
                .shadow(color: .black.opacity(0.08), radius: Constants.Spacing.xxs, x: 0, y: 1)

            Image(systemName: "chevron.right")
                .font(.system(size: Layout.chevronIconSize, weight: .semibold))
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
        HStack(spacing: theme.spacing.xs) {
            Text(label)
                .dsTextStyle(.subheadline)
            Text("\(value)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
        }
    }
}
