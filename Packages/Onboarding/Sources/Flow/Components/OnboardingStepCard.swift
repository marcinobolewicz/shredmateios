//
//  OnboardingStepCard.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Frosted glass card used by every onboarding step.
///
/// Mirrors `WelcomeCard`'s visual treatment so the post-registration flow
/// feels like a natural continuation of the welcome screen: title, body
/// copy, optional custom content slot and a single primary action button.
///
/// Steps render their own content via the `content` slot, keeping each
/// step view a thin shell over its data — copy lives in the localisation
/// bundle, layout lives here.
extension OnboardingStepCard where Content == EmptyView {
    init(
        title: String,
        description: String,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            description: description,
            actionTitle: actionTitle,
            onAction: onAction,
            content: { EmptyView() }
        )
    }
}

struct OnboardingStepCard<Content: View>: View {

    @Environment(AppTheme.self) private var theme

    let title: String
    let description: String
    let actionTitle: String?
    let onAction: (() -> Void)?
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        description: String,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            titleLabel
            descriptionLabel
            content()
                .padding(.top, theme.spacing.xs)
            if let actionTitle, let onAction {
                actionButton(title: actionTitle, action: onAction)
                    .padding(.top, theme.spacing.sm)
            }
        }
        .frame(maxWidth: .infinity)
        .dsFrostedCard()
    }

    // MARK: - Subviews

    private var titleLabel: some View {
        Text(title)
            .font(.title2.bold())
            .foregroundStyle(theme.colors.primaryForeground)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var descriptionLabel: some View {
        Text(description)
            .font(.subheadline)
            .foregroundStyle(theme.colors.primaryForeground.opacity(Self.descriptionOpacity))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(.dsPrimary)
    }

    // MARK: - Tuning

    private static var descriptionOpacity: Double { 0.85 }
}
