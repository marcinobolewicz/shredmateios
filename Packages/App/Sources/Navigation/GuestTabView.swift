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
                Label("Start", systemImage: "house")
            }
            .tag(GuestTab.welcome)
            
            PlacesRootView(
                placesService: dependencies.placesService,
            )
            .tabItem { Label("Spots", systemImage: "map") }
            .tag(UserTab.spots)

            .tabItem {
                Label("Odkrywaj", systemImage: "map")
            }
            .tag(GuestTab.explore)
            
            Color.clear
                .tabItem {
                    Label("Zaloguj", systemImage: "person.crop.circle")
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

