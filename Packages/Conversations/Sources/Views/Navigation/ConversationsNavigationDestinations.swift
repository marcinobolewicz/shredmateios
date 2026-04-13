//
//  ConversationsNavigationDestinations.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Networking

/// Builds a destination view for a rider profile, given the rider's User ID and display name.
///
/// Provided by the host module (e.g. App) so the Conversations package stays decoupled
/// from the rider profile feature.
public typealias RiderProfileDestinationBuilder = @MainActor (UUID, String) -> AnyView

struct ConversationsNavigationDestinations: ViewModifier {
    let repository: ChatRepository
    let currentUserId: String
    let riderProfileDestination: RiderProfileDestinationBuilder

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: ConversationsRoute.self) { route in
                destination(for: route)
            }
    }

    @ViewBuilder
    private func destination(for route: ConversationsRoute) -> some View {
        switch route {
        case .chat(let conversationId, let participantName):
            ChatView(
                viewModel: ChatViewModel(
                    conversationId: conversationId,
                    participantName: participantName,
                    repository: repository,
                    currentUserId: currentUserId
                )
            )
        case .riderProfile(let userId, let displayName):
            riderProfileDestination(userId, displayName)
        }
    }
}

extension View {
    func conversationsDestinations(
        repository: ChatRepository,
        currentUserId: String,
        riderProfileDestination: @escaping RiderProfileDestinationBuilder
    ) -> some View {
        modifier(ConversationsNavigationDestinations(
            repository: repository,
            currentUserId: currentUserId,
            riderProfileDestination: riderProfileDestination
        ))
    }
}
