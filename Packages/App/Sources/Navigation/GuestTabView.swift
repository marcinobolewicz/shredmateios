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
import Theme

enum GuestTab: Hashable {
    case welcome
    case explore
    case login
}

struct GuestTabView: View {
    @Environment(AppTheme.self) private var theme
    let dependencies: AppDependencies
    @State private var selectedTab: GuestTab = .welcome

    let onLoginTap: () -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            GuestWelcomeView(onSlideCTATap: { slide in
                selectedTab = slide.targetTab
            })
            .tabItem {
                Label(AppStrings.guestTabHome.localized, systemImage: "house")
            }
            .tag(GuestTab.welcome)
            
            PlacesRootView(
                placesService: dependencies.placesService,
                sportsService: dependencies.sportsService,
                riderService: dependencies.riderService,
                mentorSlotsService: dependencies.mentorSlotsService,
                sportPreferenceStorage: dependencies.sportPreferenceStorage
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
        .tint(theme.colors.primary)
        .onChange(of: selectedTab) { _, tab in
            if tab == .login {
                onLoginTap()
                selectedTab = .welcome // wracamy, bo to nie jest prawdziwy tab
            }
        }
    }
}

