//
//  WelcomeCard.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

/// Frosted glass content card overlaid on the welcome photo background.
///
/// Mirrors the visual treatment used by the guest onboarding `SlideView`:
/// `.ultraThinMaterial` background, large rounded corners, white text on
/// the dark scrim, and a stack of theme-styled action buttons.
struct WelcomeCard: View {

    @Environment(AppTheme.self) private var theme
    let onAction: (WelcomeAction) -> Void

    var body: some View {
        VStack(spacing: theme.spacing.md) {
            title
            subtitle
            WelcomeHighlightList()
                .padding(.top, theme.spacing.xs)
            WelcomeActionsView(onAction: onAction)
                .padding(.top, theme.spacing.xs)
        }
        .dsFrostedCard()
    }

    // MARK: - Subviews

    private var title: some View {
        Text(OnboardingStrings.welcomeTitle.localized)
            .font(.title.bold())
            .foregroundStyle(theme.colors.primaryForeground)
            .multilineTextAlignment(.center)
    }

    private var subtitle: some View {
        Text(OnboardingStrings.welcomeSubtitle.localized)
            .font(.body)
            .foregroundStyle(theme.colors.primaryForeground.opacity(Self.subtitleOpacity))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Tuning

    private static let subtitleOpacity: Double = 0.85
}
