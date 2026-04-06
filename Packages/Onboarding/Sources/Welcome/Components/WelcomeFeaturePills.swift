//
//  WelcomeFeaturePills.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

/// Horizontal row of feature pills sitting between the highlights and the CTAs.
///
/// Acts as a visual summary — each pill pairs a small icon with a single
/// feature label so the user can grasp the offering at a glance.
struct WelcomeFeaturePills: View {

    @Environment(AppTheme.self) private var theme
    let features: [WelcomeFeature]

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(features) { feature in
                WelcomeFeaturePill(feature: feature)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Pill

private struct WelcomeFeaturePill: View {

    @Environment(AppTheme.self) private var theme
    let feature: WelcomeFeature

    var body: some View {
        VStack(spacing: theme.spacing.xs) {
            Image(systemName: feature.systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(theme.colors.primary)

            Text(feature.title)
                .dsTextStyle(.footnote, color: \.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, minHeight: Self.pillHeight)
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    private static let pillHeight: CGFloat = 84
}
