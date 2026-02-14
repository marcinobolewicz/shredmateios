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
            HomeView(
                authState: dependencies.authState,
                riderService: dependencies.riderService
            )
            .tabItem { Label("Home", systemImage: "house") }
            .tag(UserTab.home)

            PlacesRootView(
                placesService: dependencies.placesService,
            )
            .tabItem { Label("Spots", systemImage: "map") }
            .tag(UserTab.spots)

            ConversationsView()
            .tabItem { Label("Chat", systemImage: "message") }
            .tag(UserTab.messages)

            ProfileView(
                viewModel: ProfileViewModel(
                    riderService: dependencies.riderService,
                    authState: dependencies.authState
                )
            )
            .tabItem { Label("Profil", systemImage: "person") }
            .tag(UserTab.profile)
        }
    }
}
