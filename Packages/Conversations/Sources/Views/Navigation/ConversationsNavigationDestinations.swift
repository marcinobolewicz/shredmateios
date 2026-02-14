//
//  ConversationsNavigationDestinations.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI

struct ConversationsNavigationDestinations: ViewModifier {
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
                    participantName: participantName
                )
            )
        }
    }
}

extension View {
    func conversationsDestinations() -> some View {
        modifier(ConversationsNavigationDestinations())
    }
}
