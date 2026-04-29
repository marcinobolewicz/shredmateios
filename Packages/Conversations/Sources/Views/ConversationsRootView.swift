//
//  ConversationsRootView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme
import Networking

public struct ConversationsRootView: View {
    @Environment(AppTheme.self) private var theme
    @Bindable var router: ConversationsRouter
    private let viewModel: ConversationsListViewModel
    private let repository: ChatRepository
    private let riderService: any RiderServiceProtocol
    private let currentUserId: String
    private let riderProfileDestination: RiderProfileDestinationBuilder

    public init(
        router: ConversationsRouter,
        repository: ChatRepository,
        riderService: any RiderServiceProtocol,
        currentUserId: String,
        riderProfileDestination: @escaping RiderProfileDestinationBuilder
    ) {
        self.router = router
        self.repository = repository
        self.riderService = riderService
        self.currentUserId = currentUserId
        self.riderProfileDestination = riderProfileDestination
        self.viewModel = ConversationsListViewModel(repository: repository)
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 0) {
                HStack {
                    DSScreenHeader(title: ConversationsStrings.rootNavigationTitle.localized)
                    Spacer()
                    Button {
                        router.presentNewConversation()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                    .padding(.trailing, theme.spacing.md)
                }
                ConversationsListView(viewModel: viewModel)
                    .padding(.vertical, theme.spacing.md)
            }
            .background(theme.colors.backgroundSecondary)
            .navigationBarHidden(true)
            .conversationsDestinations(
                repository: repository,
                currentUserId: currentUserId,
                riderProfileDestination: riderProfileDestination
            )
        }
        .environment(router)
        .onChange(of: router.pendingRoute) { _, route in
            guard let route else { return }
            router.pendingRoute = nil
            router.popToRoot()
            router.navigate(to: route)
        }
        .fullScreenCover(isPresented: $router.showNewConversation) {
            NewConversationView(
                viewModel: NewConversationViewModel(
                    repository: repository,
                    riderService: riderService
                )
            )
            .environment(router)
        }
    }
}
