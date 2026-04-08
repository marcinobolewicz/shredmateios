//
//  SingleSportRiderTypeView.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Single-sport flow — step 2.
///
/// Lets the user pick how they want to use ShredMate (rider vs mentor).
/// The role itself is the CTA — there is no separate confirm button and
/// no skip, because the choice steers the rest of the matching logic.
/// A reassurance footnote tells the user the role can still be changed
/// later.
struct SingleSportRiderTypeView: View {

    @Environment(AppTheme.self) private var theme

    let onSelect: (OnboardingRiderRole) -> Void

    var body: some View {
        OnboardingStepCard(
            title: OnboardingStrings.singleSportRiderTypeTitle.localized,
            description: OnboardingStrings.singleSportRiderTypeDescription.localized
        ) {
            VStack(spacing: theme.spacing.sm) {
                roleChoices
                footnote
                    .padding(.top, theme.spacing.xs)
            }
        }
    }

    // MARK: - Subviews

    private var roleChoices: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(OnboardingRiderRole.allCases) { role in
                OnboardingChoiceCard(
                    title: role.title,
                    description: role.description,
                    onTap: { onSelect(role) }
                )
            }
        }
    }

    private var footnote: some View {
        Text(OnboardingStrings.singleSportRiderTypeFootnote.localized)
            .font(.footnote)
            .foregroundStyle(theme.colors.primaryForeground.opacity(Self.footnoteOpacity))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Tuning

    private static let footnoteOpacity: Double = 0.70
}
