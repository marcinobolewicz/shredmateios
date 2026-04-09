//
//  ChatView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme

struct ChatView: View {
    @Environment(AppTheme.self) private var theme
    @State var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            messagesScrollView
            ChatInputView(text: $viewModel.inputText, onSend: viewModel.send)
        }
        .background(theme.colors.backgroundSecondary)
        .navigationTitle(viewModel.participantName)
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.loadOnAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: theme.spacing.xs) {
                    if viewModel.hasOlderMessages {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacing.sm)
                            .onAppear { viewModel.loadOlderMessages() }
                    }

                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(viewData: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.last?.id) { _, newId in
                guard let newId else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(newId, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.isLoadingOlder) { wasLoading, isLoading in
                if wasLoading && !isLoading, let anchorId = viewModel.anchorMessageId {
                    proxy.scrollTo(anchorId, anchor: .top)
                    viewModel.consumeAnchor()
                }
            }
        }
    }
}
