//
//  GuestTabView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

import SwiftUI
import Login
import Places
import Core

enum GuestTab: Hashable {
    case welcome
    case explore
    case login
}

struct GuestTabView: View {
    let dependencies: AppDependencies
    @State private var selectedTab: GuestTab = .welcome
    
    let onLoginTap: () -> Void
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GuestWelcomeView(
            )
            .tabItem {
                Label(AppStrings.guestTabHome.localized, systemImage: "house")
            }
            .tag(GuestTab.welcome)
            
            PlacesRootView(
                placesService: dependencies.placesService,
                sportsService: dependencies.sportsService,
                riderService: dependencies.riderService,
                mentorSlotsService: dependencies.mentorSlotsService
            )
            .tabItem {
                Label(AppStrings.guestTabExplore.localized, systemImage: "map")
            }
            .tag(GuestTab.explore)
            
            Color.clear
                .tabItem {
                    Label(AppStrings.guestTabLogin.localized, systemImage: "person.crop.circle")
                }
                .tag(GuestTab.login)
        }
        .onChange(of: selectedTab) { _, tab in
            if tab == .login {
                onLoginTap()
                selectedTab = .welcome // wracamy, bo to nie jest prawdziwy tab
            }
        }
    }
}

