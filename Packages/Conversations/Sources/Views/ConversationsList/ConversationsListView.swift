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
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var viewModel: ConversationsListViewModel
    @State private var pendingDeletion: ConversationRowViewData?

    var body: some View {
        content
            .task { viewModel.loadOnAppear() }
            .refreshable { viewModel.refresh() }
            .errorAlert(state: viewModel.state) { viewModel.refresh() }
            .onChange(of: scenePhase) { _, phase in
                // Scenario D: refetch the list when the app resumes so unreadCount
                // stays consistent even if a socket event was missed.
                if phase == .active {
                    viewModel.refresh()
                }
            }
            .confirmationDialog(
                ConversationsStrings.deleteConfirmTitle.localized,
                isPresented: Binding(
                    get: { pendingDeletion != nil },
                    set: { if !$0 { pendingDeletion = nil } }
                ),
                titleVisibility: .visible,
                presenting: pendingDeletion
            ) { row in
                Button(ConversationsStrings.deleteConfirmButton.localized, role: .destructive) {
                    viewModel.deleteConversation(id: row.id)
                    pendingDeletion = nil
                }
                Button(ConversationsStrings.deleteCancelButton.localized, role: .cancel) {
                    pendingDeletion = nil
                }
            } message: { _ in
                Text(ConversationsStrings.deleteConfirmMessage.localized)
            }
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
                            .contextMenu {
                                Button(role: .destructive) {
                                    pendingDeletion = row
                                } label: {
                                    Label(
                                        ConversationsStrings.deleteActionTitle.localized,
                                        systemImage: "trash"
                                    )
                                }
                            }
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
