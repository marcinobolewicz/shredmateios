//
//  SpotRow.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Theme

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
//                    TODO: handle more than one row of tags
                    ForEach(viewData.sportTags, id: \.self) { sportTag in
                        Tag(text: sportTag)
                    }
                }

                if !viewData.description.isEmpty {
                    Text(viewData.description)
                        .dsTextStyle(.subheadline)
                        .lineLimit(1)
                }

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

    @ViewBuilder
    private var avatar: some View {
        Group {
            switch viewData.avatar {
            case .initials(let text):
                ZStack {
                    Circle().fill(theme.colors.surfaceTertiary)
                    Text(text)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                }
            case .imageRemote(let url):
                if let url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Circle().fill(theme.colors.surfaceTertiary)
                        }
                    }
                    .clipShape(Circle())
                } else {
                    Circle().fill(theme.colors.surfaceTertiary)
                }
            case .image(let name):
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            }
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Supporting Views

private struct Tag: View {
    @Environment(AppTheme.self) private var theme
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(theme.colors.textSecondary)
            .padding(.horizontal, theme.spacing.xs + 2)
            .padding(.vertical, theme.spacing.xxs + 2)
            .background(
                Capsule().fill(theme.colors.surfaceTertiary)
            )
    }
}

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

