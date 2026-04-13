import SwiftUI
import Theme
import Common

struct StripeOnboardingView: View {

    @Environment(AppTheme.self) private var theme
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: StripeOnboardingViewModel

    init(viewModel: StripeOnboardingViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            DSScreenHeader(title: StripeStrings.navigationTitle.localized)
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    descriptionCard
                    if viewModel.status != nil {
                        statusCard
                    }
                    actionSection
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.lg)
            }
        }
        .background(theme.colors.backgroundSecondary)
        .task { await viewModel.loadStatus() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && viewModel.step == .awaitingReturn {
                Task { await viewModel.refreshAfterReturn() }
            }
        }
        .alert(
            CommonStrings.errorTitle.localized,
            isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button(CommonStrings.okButton.localized) { viewModel.clearError() }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    // MARK: - Description

    private var descriptionCard: some View {
        VStack(spacing: theme.spacing.sm) {
            Image(systemName: "creditcard")
                .font(.largeTitle)
                .foregroundStyle(theme.colors.primary)

            Text(StripeStrings.setupDescription.localized)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.lg)
        .background(theme.colors.background)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
    }

    // MARK: - Status

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(StripeStrings.statusTitle.localized)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)

            StatusRow(
                label: viewModel.isOnboardingComplete
                    ? StripeStrings.onboardingCompleted.localized
                    : StripeStrings.onboardingPending.localized,
                isPositive: viewModel.isOnboardingComplete,
                theme: theme
            )

            StatusRow(
                label: viewModel.arePayoutsEnabled
                    ? StripeStrings.payoutsEnabled.localized
                    : StripeStrings.payoutsDisabled.localized,
                isPositive: viewModel.arePayoutsEnabled,
                theme: theme
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.lg)
        .background(theme.colors.background)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionSection: some View {
        if viewModel.step == .awaitingReturn {
            awaitingReturnCard
        } else if viewModel.isOnboardingComplete && viewModel.arePayoutsEnabled {
            EmptyView()
        } else {
            VStack(spacing: theme.spacing.sm) {
                DSLoadingButton(
                    onboardingButtonTitle,
                    isLoading: viewModel.step == .creatingAccount
                        || viewModel.step == .creatingLink
                ) {
                    Task { await viewModel.startOnboarding() }
                }

                if viewModel.status != nil {
                    DSLoadingButton(
                        secondary: StripeStrings.refreshStatusButton.localized,
                        isLoading: viewModel.step == .refreshingStatus
                    ) {
                        Task { await viewModel.refreshAfterReturn() }
                    }
                }
            }
        }
    }

    private var awaitingReturnCard: some View {
        VStack(spacing: theme.spacing.md) {
            ProgressView()

            Text(StripeStrings.awaitingReturnMessage.localized)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.lg)
        .background(theme.colors.background)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
    }

    private var onboardingButtonTitle: String {
        viewModel.status != nil
            ? StripeStrings.continueOnboardingButton.localized
            : StripeStrings.startOnboardingButton.localized
    }
}

// MARK: - Status Row

private struct StatusRow: View {

    let label: String
    let isPositive: Bool
    let theme: AppTheme

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: isPositive ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isPositive ? theme.colors.success : theme.colors.textTertiary)

            Text(label)
                .font(theme.typography.subheadline)
                .foregroundStyle(theme.colors.textPrimary)
        }
    }
}
