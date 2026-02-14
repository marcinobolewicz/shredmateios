//
//  SpotRow.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Networking
import Theme

// MARK: - Models

enum Sport: String, CaseIterable, Identifiable {
    case snowboard = "Snowboard"
    case narty = "Narty"
    case kitesurfing = "Kitesurfing"
    case wakeboard = "Wakeboard"

    var id: String { rawValue }
}

struct Spot: Identifiable, Equatable {
    let id: UUID = .init()
    let name: String
    let city: String
    let region: String
    let sport: Sport
    let description: String
    let rating: Double
    let riders: Int
    let mentors: Int
    let avatar: Avatar

    static func spot(with place: PlaceDto) -> Spot {
        Spot(
            name: place.name,
            city: "",
            region: "",
            sport: .kitesurfing,
            description: place.description ?? "",
            rating: 3.3,
            riders: 66,
            mentors: 2,
            avatar: .initials("AA")
        )
    }
}

// MARK: - SpotRow

struct SpotRow: View {
    @Environment(AppTheme.self) private var theme
    let viewData: SpotRowViewData

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            avatar

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack {
                    Text(viewData.title)
                        .dsTextStyle(.heading)
                    Spacer()
                    Tag(text: viewData.sportTag)
                }

                Text(viewData.subtitle)
                    .dsTextStyle(.subheadline)

                Text(viewData.description)
                    .dsTextStyle(.subheadline)
                    .lineLimit(2)

                HStack(spacing: theme.spacing.sm) {
                    StatRating(value: Double(viewData.ratingText) ?? 0)
                    StatText(label: "riders", value: Int(viewData.ridersText.filter(\.isNumber)) ?? 0)
                    StatText(label: "mentors", value: Int(viewData.mentorsText.filter(\.isNumber)) ?? 0)
                }
            }

            Image(systemName: "chevron.right")
                .foregroundStyle(theme.colors.textTertiary)
                .padding(.top, theme.spacing.xxs + 2)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .strokeBorder(theme.colors.border.opacity(0.3), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var avatar: some View {
        switch viewData.avatar {
        case .initials(let text):
            ZStack {
                Circle().fill(theme.colors.surfaceTertiary)
                Text(text)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .frame(width: 46, height: 46)
        case .imageRemote:
            Circle().fill(theme.colors.surfaceTertiary)
                .frame(width: 46, height: 46)
        case .image:
            EmptyView()
        }
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

private struct StatRating: View {
    @Environment(AppTheme.self) private var theme
    let value: Double

    var body: some View {
        HStack(spacing: theme.spacing.xxs + 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.colors.warning)
            Text(String(format: "%.1f", value))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
        }
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

