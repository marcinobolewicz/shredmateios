//
//  OnboardingBulletList.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Vertical list of short feature bullets used inside `OnboardingStepCard`.
///
/// Each row is a checkmark glyph paired with a left-aligned label. The
/// checkmark is sized off the row text style and snapped to the first text
/// baseline so multi-line items still hang correctly off the icon.
struct OnboardingBulletList: View {

    @Environment(AppTheme.self) private var theme
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(items, id: \.self) { item in
                OnboardingBulletRow(text: item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Row

private struct OnboardingBulletRow: View {

    @Environment(AppTheme.self) private var theme
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            icon
            Text(text)
                .font(.subheadline)
                .foregroundStyle(theme.colors.primaryForeground)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var icon: some View {
        Image(systemName: "checkmark")
            .font(.subheadline.weight(.bold))
            .foregroundStyle(theme.colors.primaryForeground)
            .frame(width: Self.iconSlot, alignment: .center)
            .accessibilityHidden(true)
    }

    private static let iconSlot: CGFloat = 16
}
