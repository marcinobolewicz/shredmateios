//
//  WelcomeBrandHeader.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

/// Top hero block of the welcome screen: brand mark, title and subtitle.
///
/// The mark is a tinted rounded square with an SF Symbol so the component
/// stays fully self-contained and doesn't reach into the host app bundle.
struct WelcomeBrandHeader: View {

    @Environment(AppTheme.self) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.md) {
            brandMark
            title
            subtitle
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Subviews

    private var brandMark: some View {
        Image(systemName: Self.symbolName)
            .font(.system(size: Self.symbolSize, weight: .semibold))
            .foregroundStyle(theme.colors.primaryForeground)
            .frame(width: Self.markSize, height: Self.markSize)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                    .fill(theme.colors.primary)
            )
            .accessibilityLabel(OnboardingStrings.welcomeLogoAccessibility.localized)
    }

    private var title: some View {
        Text(OnboardingStrings.welcomeTitle.localized)
            .dsTextStyle(.largeTitle)
    }

    private var subtitle: some View {
        Text(OnboardingStrings.welcomeSubtitle.localized)
            .dsTextStyle(.subheadline)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Layout

    private static let markSize: CGFloat = 88
    private static let symbolSize: CGFloat = 40
    private static let symbolName: String = "figure.skiing.downhill"
}
