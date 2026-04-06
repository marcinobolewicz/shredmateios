//
//  WelcomeContent.swift
//  Onboarding
//
//  Created by ShredMate on 06/04/2026.
//

import Foundation

// MARK: - Highlight Row

/// A single bullet point describing one aspect of the product promise.
struct WelcomeHighlight: Identifiable, Hashable {
    let id: String
    let text: String
}

// MARK: - Feature Pill

/// A short, scannable feature label rendered as a pill.
struct WelcomeFeature: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
}

// MARK: - Static Content

/// Copy fed into the welcome screen.
///
/// Kept as plain data so it is trivial to unit test and so that future
/// remote/experiment-driven variants can swap it in without touching the
/// view hierarchy.
enum WelcomeContent {

    static let highlights: [WelcomeHighlight] = [
        WelcomeHighlight(
            id: "sessions",
            text: OnboardingStrings.welcomeHighlightSessions.localized
        ),
        WelcomeHighlight(
            id: "audience",
            text: OnboardingStrings.welcomeHighlightAudience.localized
        ),
        WelcomeHighlight(
            id: "personalization",
            text: OnboardingStrings.welcomeHighlightPersonalization.localized
        )
    ]

    static let features: [WelcomeFeature] = [
        WelcomeFeature(
            id: "mentor",
            title: OnboardingStrings.welcomeFeatureMentor.localized,
            systemImage: "figure.skiing.downhill"
        ),
        WelcomeFeature(
            id: "crew",
            title: OnboardingStrings.welcomeFeatureCrew.localized,
            systemImage: "person.3.fill"
        ),
        WelcomeFeature(
            id: "slots",
            title: OnboardingStrings.welcomeFeatureSlots.localized,
            systemImage: "calendar"
        )
    ]
}
