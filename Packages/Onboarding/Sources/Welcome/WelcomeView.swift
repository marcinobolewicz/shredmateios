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
/// Shown once per install before any authentication. A single screen — not
/// a paged tour — presenting the product promise and three entry points:
/// sign up, sign in, or skip for now.
///
/// Visually consistent with `SlideView` (guest onboarding pages):
/// full-bleed photo background, dark scrim for legibility, brand logo at
/// the top and a frosted glass card with the call to action.
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
        ZStack {
            scrim
            content
        }
        .dsImageBackground(Self.backgroundAssetName)
        .ignoresSafeArea()
    }

    // MARK: - Subviews

    private var scrim: some View {
        LinearGradient(
            colors: [.black.opacity(0.15), .black.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var content: some View {
        VStack(spacing: 0) {
            WelcomeBrandLogo()
                .padding(.top, theme.spacing.xxl)
            Spacer()
            WelcomeCard(onAction: onAction)
            Spacer()
        }
        .padding(.horizontal, theme.spacing.lg)
        .safeAreaPadding()
    }

    // MARK: - Constants

    private static let backgroundAssetName = "slide_1"
}

// MARK: - Preview

#Preview("Welcome") {
    WelcomeView { _ in }
        .environment(AppTheme.default)
}
