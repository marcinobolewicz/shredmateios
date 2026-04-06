//
//  WelcomeView.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import SwiftUI
import Theme

/// First-run welcome screen.
///
/// Shown once per install before any authentication. A single screen —
/// not a paged tour — presenting the product promise and three entry
/// points: sign up, sign in, or skip for now.
///
/// The view is intentionally stateless: all content is sourced from the
/// `Onboarding` localisation bundle and theme tokens, and the caller is
/// informed of user intent via a single `onAction` callback.
public struct WelcomeView: View {

    @Environment(AppTheme.self) private var theme
    private let onAction: (WelcomeAction) -> Void

    public init(onAction: @escaping (WelcomeAction) -> Void) {
        self.onAction = onAction
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.spacing.xl) {
                    WelcomeBrandHeader()
                    WelcomeHighlightList(highlights: WelcomeContent.highlights)
                    WelcomeFeaturePills(features: WelcomeContent.features)
                    Spacer(minLength: theme.spacing.md)
                    WelcomeActionsView(onAction: onAction)
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.top, theme.spacing.xl)
                .padding(.bottom, theme.spacing.lg)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
        }
        .welcomeBackground()
    }
}

// MARK: - Preview

#Preview("Welcome") {
    WelcomeView { _ in }
        .environment(AppTheme.default)
}
