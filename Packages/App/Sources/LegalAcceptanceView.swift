import SwiftUI
import Networking
import Theme

/// Blocking screen shown when the logged-in user must accept updated
/// versions of legal documents (`AuthState.pendingLegalDocuments`).
///
/// The user can either accept all pending documents or decline, which
/// ends the session — there is no way to dismiss the screen otherwise.
struct LegalAcceptanceView: View {

    @Environment(AppTheme.self) private var theme
    @Environment(AuthState.self) private var authState

    @State private var isProcessing = false
    @State private var showError = false

    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(theme.colors.primary)

            Text(AppStrings.legalUpdateTitle.localized)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(AppStrings.legalUpdateMessage.localized)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            documentList

            Spacer()

            DSLoadingButton(
                AppStrings.legalAcceptButton.localized,
                isLoading: isProcessing,
                isDisabled: isProcessing
            ) {
                Task { await accept() }
            }

            Button(AppStrings.legalDeclineButton.localized) {
                Task { await decline() }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .disabled(isProcessing)
        }
        .padding(theme.spacing.lg)
        .interactiveDismissDisabled()
        .alert(AppStrings.legalAcceptError.localized, isPresented: $showError) {
            Button("OK") {}
        }
    }

    private var documentList: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(authState.pendingLegalDocuments) { document in
                if let url = URL(string: document.url) {
                    Link(destination: url) {
                        HStack {
                            Text(Self.displayName(for: document.type))
                                .font(.body.weight(.medium))
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                        .padding(theme.spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radius.md)
                                .fill(theme.colors.primary.opacity(0.08))
                        )
                    }
                    .foregroundStyle(theme.colors.primary)
                }
            }
        }
    }

    private static func displayName(for type: LegalDocumentType) -> String {
        switch type {
        case .terms: AppStrings.legalDocTerms.localized
        case .mentorTerms: AppStrings.legalDocMentorTerms.localized
        case .privacy: AppStrings.legalDocPrivacy.localized
        case .unknown: AppStrings.legalDocUnknown.localized
        }
    }

    private func accept() async {
        isProcessing = true
        let success = await authState.acceptPendingLegalDocuments()
        isProcessing = false
        if !success {
            showError = true
        }
    }

    private func decline() async {
        isProcessing = true
        await authState.declinePendingLegalDocuments()
        isProcessing = false
    }
}
