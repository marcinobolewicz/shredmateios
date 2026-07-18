//
//  UserTab.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import SwiftUI
import Profile
import Places
import Conversations
import Feed
import Core
import Networking
import Theme

enum UserTab: Hashable {
    case home
    case spots
    case mentors
    case messages
    case profile
}

struct UserTabView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(AppRouter.self) private var router
    let dependencies: AppDependencies

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            FeedView(
                feedService: dependencies.feedService,
                placesService: dependencies.placesService,
                riderService: dependencies.riderService,
                mentorSlotsService: dependencies.mentorSlotsService,
                sportPreferenceStorage: dependencies.sportPreferenceStorage,
                onOpenChat: openChat
            )
            .tabItem { Label(AppStrings.userTabHome.localized, systemImage: "house") }
            .tag(UserTab.home)

            PlacesRootView(
                placesService: dependencies.placesService,
                sportsService: dependencies.sportsService,
                riderService: dependencies.riderService,
                mentorSlotsService: dependencies.mentorSlotsService,
                sportPreferenceStorage: dependencies.sportPreferenceStorage,
                onOpenChat: openChat
            )
            .tabItem { Label(AppStrings.userTabSpots.localized, systemImage: "map") }
            .tag(UserTab.spots)

            MentorsRootView(
                mentorsService: dependencies.mentorsService,
                sportsService: dependencies.sportsService,
                placesService: dependencies.placesService,
                riderService: dependencies.riderService,
                mentorSlotsService: dependencies.mentorSlotsService,
                sportPreferenceStorage: dependencies.sportPreferenceStorage,
                onOpenChat: openChat
            )
            .tabItem { Label(AppStrings.userTabMentors.localized, systemImage: "person.badge.shield.checkmark") }
            .tag(UserTab.mentors)

            ConversationsView(
                router: router.conversations,
                repository: dependencies.chatRepository,
                riderService: dependencies.riderService,
                currentUserId: dependencies.authState.user?.id ?? "",
                riderProfileDestination: makeRiderProfileDestination
            )
            .tabItem { Label(AppStrings.userTabChat.localized, systemImage: "message") }
            .tag(UserTab.messages)
            .badge(unreadConversationsBadge)

            ProfileView(
                viewModel: ProfileViewModel(
                    riderService: dependencies.riderService,
                    sportsService: dependencies.sportsService,
                    placesService: dependencies.placesService,
                    feedService: dependencies.feedService,
                    mentorSlotsService: dependencies.mentorSlotsService,
                    stripeService: dependencies.stripeService,
                    authState: dependencies.authState,
                    legalService: dependencies.legalService
                ),
                path: $router.profilePath
            )
            .tabItem { Label(AppStrings.userTabProfile.localized, systemImage: "person") }
            .tag(UserTab.profile)
        }
        .tint(theme.colors.primary)
    }

    // MARK: - Badge

    private var unreadConversationsBadge: Text? {
        let count = dependencies.chatRepository.unreadConversationsCount
        guard count > 0 else { return nil }
        return Text(count > 9 ? "9+" : "\(count)")
    }

    /// Builds a rider profile destination for the Conversations module by user ID.
    /// Kept here so the Conversations package stays decoupled from the Places feature.
    @MainActor
    private func makeRiderProfileDestination(userId: UUID, displayName: String) -> AnyView {
        AnyView(
            RiderByUserLoadingView(
                userId: userId,
                displayName: displayName,
                riderService: dependencies.riderService,
                mentorSlotsService: dependencies.mentorSlotsService,
                stripePaymentService: dependencies.stripePaymentService,
                onMessageTap: openChat
            )
        )
    }

    private func openChat(userId: UUID, displayName: String) {
        Task {
            do {
                let conversation = try await dependencies.chatRepository.openOrCreateConversation(
                    otherUserId: userId.uuidString.lowercased()
                )
                router.handle(
                    .conversation(id: conversation.id, participantName: displayName)
                )
            } catch {
                // Chat creation failed silently — conversation tab not switched.
            }
        }
    }
}
