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

enum UserTab: Hashable {
    case home
    case spots
    case messages
    case profile
}

struct UserTabView: View {
    let dependencies: AppDependencies
    @State private var selectedTab: UserTab = .home
    @State private var conversationsRouter = ConversationsRouter()

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(feedService: dependencies.feedService, placesService: dependencies.placesService, riderService: dependencies.riderService, mentorSlotsService: dependencies.mentorSlotsService, onOpenChat: openChat)
            .tabItem { Label(AppStrings.userTabHome.localized, systemImage: "house") }
            .tag(UserTab.home)

            PlacesRootView(
                placesService: dependencies.placesService,
                sportsService: dependencies.sportsService,
                riderService: dependencies.riderService,
                mentorSlotsService: dependencies.mentorSlotsService,
                onOpenChat: openChat
            )
            .tabItem { Label(AppStrings.userTabSpots.localized, systemImage: "map") }
            .tag(UserTab.spots)

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
