//
//  NewConversationView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme
import Common

struct NewConversationView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(ConversationsRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: NewConversationViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                content
            }
            .background(theme.colors.background)
            .navigationTitle(ConversationsStrings.newConversationTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(CommonStrings.cancelButton.localized) { dismiss() }
                }
            }
            .disabled(viewModel.isCreating)
            .overlay {
                if viewModel.isCreating {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)
                    }
                }
            }
            .task { viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded:
            ridersList

        case .failed:
            ContentUnavailableView {
                Label(ConversationsStrings.listFailedTitle.localized, systemImage: "exclamationmark.triangle")
            } description: {
                Text(ConversationsStrings.listFailedDescription.localized)
            } actions: {
                Button(CommonStrings.retryButton.localized) { viewModel.retry() }
                    .buttonStyle(.dsPrimary)
            }
        }
    }

    private var searchBar: some View {
        DSSearchBar(ConversationsStrings.searchRiderPlaceholder.localized, text: $viewModel.searchText)
            .padding(theme.spacing.md)
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.onSearchChanged()
            }
    }

    private var ridersList: some View {
        List(viewModel.riders) { rider in
            Button {
                startConversation(with: rider)
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    riderAvatar(rider)

                    Text(rider.displayName)
                        .dsTextStyle(.body)

                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func riderAvatar(_ rider: RiderSearchRowViewData) -> some View {
        if let url = rider.avatarURL {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                riderInitialsCircle(rider.avatarInitials)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
        } else {
            riderInitialsCircle(rider.avatarInitials)
        }
    }

    private func riderInitialsCircle(_ initials: String) -> some View {
        ZStack {
            Circle()
                .fill(theme.colors.surfaceTertiary)
            Text(initials)
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(width: 40, height: 40)
    }

    private func startConversation(with rider: RiderSearchRowViewData) {
        Task {
            await viewModel.startConversation(with: rider)

            guard let conversation = viewModel.createdConversation else { return }

            dismiss()

            // Small delay to let the sheet dismiss before navigating
            try? await Task.sleep(for: .milliseconds(300))
            router.navigate(to: .chat(
                conversationId: conversation.id,
                participantName: conversation.otherUser.name ?? conversation.otherUser.email ?? ""
            ))
        }
    }
}
