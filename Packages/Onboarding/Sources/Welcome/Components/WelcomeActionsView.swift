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
/// Two clearly ranked options: create account (primary) or sign in
/// (secondary). Dismissal is handled by the close button overlay.
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
        }
    }
}
