//
//  ConversationsNavigationDestinations.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Networking

struct ConversationsNavigationDestinations: ViewModifier {
    let repository: ChatRepository
    let currentUserId: String

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
        }
    }
}

extension View {
    func conversationsDestinations(
        repository: ChatRepository,
        currentUserId: String
    ) -> some View {
        modifier(ConversationsNavigationDestinations(
            repository: repository,
            currentUserId: currentUserId
        ))
    }
}
