import SwiftUI
import Theme
import Networking
import Common

/// Overflow menu with the moderation actions required for user-generated content
/// (App Store Guideline 1.2): report a user and block/unblock them. Shown on
/// another rider's profile — never on your own.
struct ReportBlockMenu: View {
    let riderId: String
    let userId: String?
    let displayName: String

    @Environment(ModerationService.self) private var moderation

    @State private var showReasons = false
    @State private var isProcessing = false
    @State private var resultMessage: String?

    var body: some View {
        Menu {
            Button {
                showReasons = true
            } label: {
                Label(PlacesStrings.moderationReportUser.localized, systemImage: "flag")
            }

            if let userId {
                if moderation.isBlocked(userId: userId) {
                    Button {
                        Task { await unblock(userId) }
                    } label: {
                        Label(PlacesStrings.moderationUnblockUser(displayName), systemImage: "person.crop.circle.badge.checkmark")
                    }
                } else {
                    Button(role: .destructive) {
                        Task { await block(userId) }
                    } label: {
                        Label(PlacesStrings.moderationBlockUser(displayName), systemImage: "hand.raised")
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .accessibilityLabel(PlacesStrings.moderationMenu.localized)
        }
        .disabled(isProcessing)
        .confirmationDialog(
            PlacesStrings.moderationReportTitle.localized,
            isPresented: $showReasons,
            titleVisibility: .visible
        ) {
            ForEach(ReportReason.allCases) { reason in
                Button(reason.localizedLabel) {
                    Task { await report(reason) }
                }
            }
            Button(CommonStrings.cancelButton.localized, role: .cancel) {}
        }
        .alert(
            resultMessage ?? "",
            isPresented: .init(get: { resultMessage != nil }, set: { if !$0 { resultMessage = nil } })
        ) {
            Button(CommonStrings.okButton.localized) { resultMessage = nil }
        }
        .task { await moderation.refreshBlocks() }
    }

    private func report(_ reason: ReportReason) async {
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await moderation.report(targetType: .rider, targetId: riderId, reason: reason)
            resultMessage = PlacesStrings.moderationReportSuccess.localized
        } catch {
            resultMessage = PlacesStrings.moderationActionFailed.localized
        }
    }

    private func block(_ userId: String) async {
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await moderation.block(userId: userId)
            resultMessage = PlacesStrings.moderationBlockSuccess(displayName)
        } catch {
            resultMessage = PlacesStrings.moderationActionFailed.localized
        }
    }

    private func unblock(_ userId: String) async {
        isProcessing = true
        defer { isProcessing = false }
        do {
            try await moderation.unblock(userId: userId)
        } catch {
            resultMessage = PlacesStrings.moderationActionFailed.localized
        }
    }
}
