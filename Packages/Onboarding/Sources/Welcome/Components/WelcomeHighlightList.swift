//
//  WelcomeHighlightList.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

/// Vertical list of three short bullet points describing the product promise.
///
/// Rendered inside the welcome card on top of the frosted glass background,
/// so bullets and text both use the brand foreground colour for legibility.
struct WelcomeHighlightList: View {

    @Environment(AppTheme.self) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(Self.highlights, id: \.self) { key in
                WelcomeHighlightRow(text: key.localized)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Content

    private static let highlights: [OnboardingStrings] = [
        .welcomeHighlightSessions,
        .welcomeHighlightAudience,
        .welcomeHighlightPersonalization
    ]
}

// MARK: - Row

private struct WelcomeHighlightRow: View {

    @Environment(AppTheme.self) private var theme
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            bullet
            Text(text)
                .font(.subheadline)
                .foregroundStyle(theme.colors.primaryForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var bullet: some View {
        Circle()
            .fill(theme.colors.primaryForeground)
            .frame(width: Self.bulletSize, height: Self.bulletSize)
            .alignmentGuide(.firstTextBaseline) { dim in dim[.bottom] - Self.bulletBaselineNudge }
    }

    private static let bulletSize: CGFloat = 5
    private static let bulletBaselineNudge: CGFloat = 3
}
