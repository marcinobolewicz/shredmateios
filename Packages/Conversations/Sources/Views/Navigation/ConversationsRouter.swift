//
//  ConversationsRouter.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI

@Observable
public final class ConversationsRouter {
    public var path = NavigationPath()
    public var showNewConversation = false
    public var pendingRoute: ConversationsRoute?

    public init() {}

    public func navigate(to route: ConversationsRoute) {
        path.append(route)
    }

    public func openChat(conversationId: String, participantName: String) {
        pendingRoute = .chat(conversationId: conversationId, participantName: participantName)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path = NavigationPath()
    }

    public func presentNewConversation() {
        showNewConversation = true
    }

    public func dismissNewConversation() {
        showNewConversation = false
    }
}
