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
    @State private var viewModel = NewConversationViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                ridersList
            }
            .background(theme.colors.background)
            .navigationTitle(ConversationsStrings.newConversationTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(CommonStrings.cancelButton.localized) { dismiss() }
                }
            }
            .task { viewModel.load() }
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
        dismiss()

        // Small delay to let the sheet dismiss before navigating
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            router.navigate(to: .chat(
                conversationId: UUID(), // New conversation
                participantName: rider.displayName
            ))
        }
    }
}
