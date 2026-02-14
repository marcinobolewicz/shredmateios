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
    private let repository: ChatRepository
    private let riderService: any RiderServiceProtocol
    private let currentUserId: String

    public init(
        repository: ChatRepository,
        riderService: any RiderServiceProtocol,
        currentUserId: String
    ) {
        self.repository = repository
        self.riderService = riderService
        self.currentUserId = currentUserId
    }

    public var body: some View {
        ConversationsRootView(
            repository: repository,
            riderService: riderService,
            currentUserId: currentUserId
        )
    }
}
