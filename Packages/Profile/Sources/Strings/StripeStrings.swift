import Foundation

enum StripeStrings: String {
    case navigationTitle = "stripe.navigation_title"
    case setupDescription = "stripe.setup_description"
    case startOnboardingButton = "stripe.start_onboarding_button"
    case continueOnboardingButton = "stripe.continue_onboarding_button"
    case refreshStatusButton = "stripe.refresh_status_button"
    case statusTitle = "stripe.status_title"
    case onboardingCompleted = "stripe.onboarding_completed"
    case onboardingPending = "stripe.onboarding_pending"
    case chargesEnabled = "stripe.charges_enabled"
    case chargesDisabled = "stripe.charges_disabled"
    case payoutsEnabled = "stripe.payouts_enabled"
    case payoutsDisabled = "stripe.payouts_disabled"
    case awaitingReturnMessage = "stripe.awaiting_return_message"
    case invalidOnboardingURL = "stripe.invalid_onboarding_url"
    case invalidDashboardURL = "stripe.invalid_dashboard_url"

    case failedLoadStatusFormat = "stripe.failed_load_status_format"
    case failedCreateAccountFormat = "stripe.failed_create_account_format"
    case failedCreateLinkFormat = "stripe.failed_create_link_format"
    case failedRefreshStatusFormat = "stripe.failed_refresh_status_format"
    case failedDashboardLinkFormat = "stripe.failed_dashboard_link_format"

    case returnStatusSuccess = "stripe.return_status_success"
    case returnStatusPending = "stripe.return_status_pending"
    case returnStatusRestricted = "stripe.return_status_restricted"

    case walletTitle = "stripe.wallet_title"
    case walletAvailableLabel = "stripe.wallet_available_label"
    case walletPendingLabel = "stripe.wallet_pending_label"
    case walletPendingTooltip = "stripe.wallet_pending_tooltip"
    case walletPayoutsInfo = "stripe.wallet_payouts_info"
    case walletUnavailable = "stripe.wallet_unavailable"
    case openDashboardButton = "stripe.open_dashboard_button"
    case refreshBalanceButton = "stripe.refresh_balance_button"

    var localized: String {
        NSLocalizedString(rawValue, bundle: .module, comment: "")
    }

    static func failedLoadStatus(_ error: String) -> String {
        String(
            format: NSLocalizedString(
                StripeStrings.failedLoadStatusFormat.rawValue,
                bundle: .module, comment: ""
            ), error
        )
    }

    static func failedCreateAccount(_ error: String) -> String {
        String(
            format: NSLocalizedString(
                StripeStrings.failedCreateAccountFormat.rawValue,
                bundle: .module, comment: ""
            ), error
        )
    }

    static func failedCreateLink(_ error: String) -> String {
        String(
            format: NSLocalizedString(
                StripeStrings.failedCreateLinkFormat.rawValue,
                bundle: .module, comment: ""
            ), error
        )
    }

    static func failedRefreshStatus(_ error: String) -> String {
        String(
            format: NSLocalizedString(
                StripeStrings.failedRefreshStatusFormat.rawValue,
                bundle: .module, comment: ""
            ), error
        )
    }

    static func failedDashboardLink(_ error: String) -> String {
        String(
            format: NSLocalizedString(
                StripeStrings.failedDashboardLinkFormat.rawValue,
                bundle: .module, comment: ""
            ), error
        )
    }
}
