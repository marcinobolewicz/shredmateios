//
//  OnboardingChoiceCard.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Tappable option card used inside `OnboardingStepCard` for explicit
/// choices (e.g. role pick).
///
/// Renders a title + short description on a translucent surface that sits
/// well on top of the parent frosted card. The whole card is the hit
/// target; tap dispatches a single closure. Stateless — selection state
/// (if any) lives with the caller.
struct OnboardingChoiceCard: View {

    @Environment(AppTheme.self) private var theme

    let title: String
    let description: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                titleLabel
                descriptionLabel
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, theme.spacing.md)
            .padding(.horizontal, theme.spacing.md)
            .background(background)
            .overlay(border)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Subviews

    private var titleLabel: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(theme.colors.primaryForeground)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var descriptionLabel: some View {
        Text(description)
            .font(.subheadline)
            .foregroundStyle(theme.colors.primaryForeground.opacity(Self.descriptionOpacity))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var background: some View {
        shape.fill(Color.white.opacity(Self.fillOpacity))
    }

    private var border: some View {
        shape.strokeBorder(
            Color.white.opacity(Self.strokeOpacity),
            lineWidth: Self.strokeWidth
        )
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
    }

    // MARK: - Tuning

    private static let descriptionOpacity: Double = 0.80
    private static let fillOpacity: Double = 0.10
    private static let strokeOpacity: Double = 0.30
    private static let strokeWidth: CGFloat = 1
}
