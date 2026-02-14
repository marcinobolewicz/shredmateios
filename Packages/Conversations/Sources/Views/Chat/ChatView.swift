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
        .background(theme.colors.background)
        .navigationTitle(viewModel.participantName)
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.loadOnAppear() }
    }

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: theme.spacing.xs) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(viewData: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                }
            }
        }
    }
}
