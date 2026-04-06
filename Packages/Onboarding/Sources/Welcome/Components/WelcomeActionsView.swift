//
//  WelcomeActionsView.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

/// Action block at the bottom of the welcome screen.
///
/// Three clearly ranked options: create account (primary), sign in
/// (secondary), or skip for now (ghost).
struct WelcomeActionsView: View {

    @Environment(AppTheme.self) private var theme
    let onAction: (WelcomeAction) -> Void

    var body: some View {
        VStack(spacing: theme.spacing.sm) {
            Button(OnboardingStrings.welcomeActionSignUp.localized) {
                onAction(.signUp)
            }
            .buttonStyle(.dsPrimary)

            Button(OnboardingStrings.welcomeActionSignIn.localized) {
                onAction(.signIn)
            }
            .buttonStyle(.dsSecondary)

            Button(OnboardingStrings.welcomeActionLater.localized) {
                onAction(.later)
            }
            .buttonStyle(.dsGhost)
            .padding(.top, theme.spacing.xxs)
        }
    }
}
