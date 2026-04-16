//
//  AppRouter.swift
//  ShredMate
//

import SwiftUI
import Conversations
import Profile

/// Single source of truth for in-app navigation state.
///
/// Holds the currently selected tab and per-tab navigation paths so any
/// caller — onboarding flow, push notification handler, deep link parser,
/// in-app banner — can drive the UI through one uniform entry point
/// (`handle(_:)`) instead of poking private feature routers directly.
///
/// Sub-routers (e.g. `ConversationsRouter`) are kept as separate types
/// because they own state internal to the feature (`NavigationPath`,
/// pending presentations, …); `AppRouter` aggregates them so the views
/// can read everything from one environment object.
@Observable
@MainActor
final class AppRouter {

    // Top-level tab.
var selectedTab: UserTab = .home

    // Per-tab navigation paths owned by `AppRouter` so deep links can be
    // applied at any moment, not just on the first render.
var profilePath: [ProfileRoute] = []

    // Sub-routers exposed as nested observables. Their internals stay in
    // their owning module; `AppRouter` only forwards intents to them.
let conversations: ConversationsRouter

init(conversations: ConversationsRouter = ConversationsRouter()) {
        self.conversations = conversations
    }

    // MARK: - Deep link entry point

    /// Routes any in-app intent to the right corner of the UI.
    ///
    /// All sources of navigation should funnel through this method:
    /// onboarding completion, push notification taps, in-app notification
    /// taps, URL deep links. Adding a new destination is a single switch
    /// case here, not three call sites scattered across views.
func handle(_ deepLink: DeepLink) {
        switch deepLink {
        case .home:
            selectedTab = .home

        case .editProfile:
            switchTo(.profile, profileRoute: .editRider)

        case .explorePlaces:
            selectedTab = .spots

        case .findMentor:
            selectedTab = .mentors

        case .addSlots:
            switchTo(.profile, profileRoute: .generateSlots)

        case let .conversation(id, participantName):
            selectedTab = .messages
            conversations.openChat(
                conversationId: id,
                participantName: participantName
            )

        case .stripeOnboardingResult(let status):
            switchTo(.profile, profileRoute: .stripeOnboardingReturn(status: status))
        }
    }

    // MARK: - Helpers

    private func switchTo(_ tab: UserTab, profileRoute: ProfileRoute?) {
        selectedTab = tab
        if let profileRoute {
            profilePath = [profileRoute]
        }
    }
}
