//
//  SingleSportSuccessView.swift
//  Onboarding
//

import SwiftUI
import Theme

/// Single-sport flow — step 3.
///
/// Confirms the role the user just picked, lists what they can do next,
/// and offers role-aware shortcuts into the rest of the app. Each CTA
/// dispatches an `OnboardingDestination`; navigation itself happens in
/// the host so this view stays purely about presentation.
struct SingleSportSuccessView: View {

    @Environment(AppTheme.self) private var theme

    let role: OnboardingRiderRole
    let onPick: (OnboardingDestination) -> Void

    var body: some View {
        OnboardingStepCard(
            title: copy.title,
            description: copy.description
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                OnboardingBulletList(items: copy.bullets)
                actions
            }
        }
    }

    // MARK: - Subviews

    private var actions: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(copy.actions) { action in
                actionButton(for: action)
            }
        }
        .padding(.top, theme.spacing.xs)
    }

    @ViewBuilder
    private func actionButton(for action: Action) -> some View {
        switch action.style {
        case .primary:
            Button(action.title) { onPick(action.destination) }
                .buttonStyle(.dsPrimary)
        case .secondary:
            Button(action.title) { onPick(action.destination) }
                .buttonStyle(.dsSecondary)
        }
    }

    // MARK: - Copy

    private var copy: RoleCopy { RoleCopy(role: role) }
}

// MARK: - Role-aware copy

private struct RoleCopy {

    let role: OnboardingRiderRole

    var title: String {
        switch role {
        case .rider: return OnboardingStrings.singleSportSuccessRiderTitle.localized
        case .mentor: return OnboardingStrings.singleSportSuccessMentorTitle.localized
        }
    }

    var description: String {
        switch role {
        case .rider: return OnboardingStrings.singleSportSuccessRiderDescription.localized
        case .mentor: return OnboardingStrings.singleSportSuccessMentorDescription.localized
        }
    }

    var bullets: [String] {
        switch role {
        case .rider:
            return [
                OnboardingStrings.singleSportSuccessRiderBulletOne.localized,
                OnboardingStrings.singleSportSuccessRiderBulletTwo.localized,
                OnboardingStrings.singleSportSuccessRiderBulletThree.localized
            ]
        case .mentor:
            return [
                OnboardingStrings.singleSportSuccessMentorBulletOne.localized,
                OnboardingStrings.singleSportSuccessMentorBulletTwo.localized,
                OnboardingStrings.singleSportSuccessMentorBulletThree.localized
            ]
        }
    }

    var actions: [Action] {
        let primary = Action(
            id: "role-primary",
            title: roleSpecificActionTitle,
            destination: roleSpecificDestination,
            style: .primary
        )
        let editProfile = Action(
            id: "edit-profile",
            title: OnboardingStrings.singleSportSuccessActionEditProfile.localized,
            destination: .editProfile,
            style: .secondary
        )
        let explorePlaces = Action(
            id: "explore-places",
            title: OnboardingStrings.singleSportSuccessActionExplorePlaces.localized,
            destination: .explorePlaces,
            style: .secondary
        )
        return [primary, editProfile, explorePlaces]
    }

    private var roleSpecificActionTitle: String {
        switch role {
        case .rider: return OnboardingStrings.singleSportSuccessActionFindMentor.localized
        case .mentor: return OnboardingStrings.singleSportSuccessActionAddSlots.localized
        }
    }

    private var roleSpecificDestination: OnboardingDestination {
        switch role {
        case .rider: return .findMentor
        case .mentor: return .addSlots
        }
    }
}

// MARK: - Action model

private struct Action: Identifiable {
    enum Style { case primary, secondary }

    let id: String
    let title: String
    let destination: OnboardingDestination
    let style: Style
}
