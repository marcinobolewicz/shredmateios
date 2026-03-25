//
//  ConversationsView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//
//  This file is kept for backward compatibility.
//  The main entry point is ConversationsRootView.
//

import SwiftUI
import Networking

public struct ConversationsView: View {
    private let router: ConversationsRouter
    private let repository: ChatRepository
    private let riderService: any RiderServiceProtocol
    private let currentUserId: String

    public init(
        router: ConversationsRouter,
        repository: ChatRepository,
        riderService: any RiderServiceProtocol,
        currentUserId: String
    ) {
        self.router = router
        self.repository = repository
        self.riderService = riderService
        self.currentUserId = currentUserId
    }

    public var body: some View {
        ConversationsRootView(
            router: router,
            repository: repository,
            riderService: riderService,
            currentUserId: currentUserId
        )
    }
}
