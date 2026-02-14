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
                List(viewModel.rows) { row in
                    ConversationRowView(viewData: row)
                        .listRowInsets(
                            EdgeInsets(
                                top: theme.spacing.xxs,
                                leading: theme.spacing.md,
                                bottom: theme.spacing.xxs,
                                trailing: theme.spacing.md
                            )
                        )
                        .listRowSeparator(.visible)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            router.navigate(to: .chat(
                                conversationId: row.id,
                                participantName: row.participantName
                            ))
                        }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(theme.colors.background)
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
