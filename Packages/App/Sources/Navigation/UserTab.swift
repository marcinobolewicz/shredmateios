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

enum UserTab: Hashable {
    case home
    case spots
    case messages
    case profile
}

struct UserTabView: View {
    let dependencies: AppDependencies
    @State private var selectedTab: UserTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(feedService: dependencies.feedService, placesService: dependencies.placesService, riderService: dependencies.riderService)
            .tabItem { Label(AppStrings.userTabHome.localized, systemImage: "house") }
            .tag(UserTab.home)

            PlacesRootView(
                placesService: dependencies.placesService,
                sportsService: dependencies.sportsService
            )
            .tabItem { Label(AppStrings.userTabSpots.localized, systemImage: "map") }
            .tag(UserTab.spots)

            ConversationsView(
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
                    authState: dependencies.authState
                )
            )
            .tabItem { Label(AppStrings.userTabProfile.localized, systemImage: "person") }
            .tag(UserTab.profile)
        }
    }
}
