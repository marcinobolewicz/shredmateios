//
//  AuthCardHeader.swift
//  Login
//

import SwiftUI
import Theme

/// Title + subtitle pair styled for the top of an auth frosted card.
///
/// Mirrors the welcome card's header treatment so login, register and
/// reset-password screens speak the same visual language: bold white title
/// over a slightly dimmed white subtitle, both centred and self-sizing
/// vertically.
struct AuthCardHeader: View {

    @Environment(AppTheme.self) private var theme
    let title: String
    let subtitle: String?

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: theme.spacing.xs) {
            titleText
            subtitleText
        }
    }

    // MARK: - Subviews

    private var titleText: some View {
        Text(title)
            .font(.title.bold())
            .foregroundStyle(theme.colors.primaryForeground)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var subtitleText: some View {
        if let subtitle {
            Text(subtitle)
                .font(.body)
                .foregroundStyle(theme.colors.primaryForeground.opacity(Self.subtitleOpacity))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Tuning

    private static let subtitleOpacity: Double = 0.85
}
