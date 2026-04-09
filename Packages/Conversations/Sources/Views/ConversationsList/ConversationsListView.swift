//
//  ConversationsListView.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 14/02/2026.
//

import SwiftUI
import Theme
import Common

struct ConversationsListView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(ConversationsRouter.self) private var router
    @Bindable var viewModel: ConversationsListViewModel

    var body: some View {
        content
            .task { viewModel.loadOnAppear() }
            .refreshable { viewModel.refresh() }
            .errorAlert(state: viewModel.state) { viewModel.refresh() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            List {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)

        case .loaded:
            if viewModel.rows.isEmpty {
                ContentUnavailableView(
                    ConversationsStrings.listEmptyTitle.localized,
                    systemImage: "message",
                    description: Text(ConversationsStrings.listEmptyDescription.localized)
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.rows) { row in
                            Button {
                                router.navigate(to: .chat(
                                    conversationId: row.id,
                                    participantName: row.participantName
                                ))
                            } label: {
                                ConversationRowView(viewData: row)
                                    .padding(.horizontal, theme.spacing.md)
                            }
                            .buttonStyle(.plain)
                            .onAppear { viewModel.onRowAppear(row) }

                            if row.id != viewModel.rows.last?.id {
                                Divider()
                                    .padding(.horizontal, theme.spacing.md)
                            }
                        }
                    }
                }
            }

        case .failed:
            ContentUnavailableView {
                Label(ConversationsStrings.listFailedTitle.localized, systemImage: "exclamationmark.triangle")
            } description: {
                Text(ConversationsStrings.listFailedDescription.localized)
            } actions: {
                Button(CommonStrings.retryButton.localized, action: viewModel.refresh)
                    .buttonStyle(.dsPrimary)
            }
        }
    }
}
