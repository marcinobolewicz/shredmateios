//
//  WelcomeBrandLogo.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

/// Brand logo rendered above the welcome card.
///
/// Uses the outline `shredmate-logo` asset from the host app's main bundle
/// in template rendering mode, so it picks up the brand foreground colour
/// from the theme — matching the launch screen and the splash view.
struct WelcomeBrandLogo: View {

    @Environment(AppTheme.self) private var theme

    var body: some View {
        Image("shredmate-logo", bundle: .main)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundStyle(theme.colors.primaryForeground)
            .frame(width: Self.size, height: Self.size)
            .accessibilityLabel(OnboardingStrings.welcomeLogoAccessibility.localized)
    }

    // MARK: - Layout

    private static let size: CGFloat = 96
}
