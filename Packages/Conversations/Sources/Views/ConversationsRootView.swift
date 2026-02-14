//
//  ConversationsRootView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme

public struct ConversationsRootView: View {
    @State private var router = ConversationsRouter()
    @State private var viewModel = ConversationsListViewModel()

    public init() {}

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            ConversationsListView(viewModel: viewModel)
                .navigationTitle("Konwersacje")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            router.presentNewConversation()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .conversationsDestinations()
        }
        .environment(router)
        .fullScreenCover(isPresented: $router.showNewConversation) {
            NewConversationView()
                .environment(router)
        }
    }
}
