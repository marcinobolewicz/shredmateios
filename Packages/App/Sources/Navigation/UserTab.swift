//
//  File.swift
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
    let dependencies: AppDependencies
    @State private var selectedTab: UserTab = .home
    @State private var conversationsRouter = ConversationsRouter()

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(feedService: dependencies.feedService, placesService: dependencies.placesService, riderService: dependencies.riderService, mentorSlotsService: dependencies.mentorSlotsService, sportPreferenceStorage: dependencies.sportPreferenceStorage, onOpenChat: openChat)
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
                router: conversationsRouter,
                repository: dependencies.chatRepository,
                riderService: dependencies.riderService,
                currentUserId: dependencies.authState.user?.id ?? ""
            )
            .tabItem { Label(AppStrings.userTabChat.localized, systemImage: "message") }
            .tag(UserTab.messages)

            ProfileView(
                viewModel: ProfileViewModel(
                    riderService: dependencies.riderService,
                    sportsService: dependencies.sportsService,
                    placesService: dependencies.placesService,
                    feedService: dependencies.feedService,
                    mentorSlotsService: dependencies.mentorSlotsService,
                    authState: dependencies.authState
                )
            )
            .tabItem { Label(AppStrings.userTabProfile.localized, systemImage: "person") }
            .tag(UserTab.profile)
        }
        .tint(theme.colors.primary)
    }

    private func openChat(userId: UUID, displayName: String) {
        Task {
            do {
                let conversation = try await dependencies.chatRepository.openOrCreateConversation(
                    otherUserId: userId.uuidString.lowercased()
                )
                conversationsRouter.openChat(
                    conversationId: conversation.id,
                    participantName: displayName
                )
                selectedTab = .messages
            } catch {
                // Chat creation failed silently — conversation tab not switched
            }
        }
    }
}
