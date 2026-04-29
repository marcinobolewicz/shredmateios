import Foundation

// MARK: - Stripe Account

public struct StripeAccount: Codable, Sendable, Equatable {
    public let stripeAccountId: String
    public let chargesEnabled: Bool
    public let detailsSubmitted: Bool
    public let payoutsEnabled: Bool

    public init(
        stripeAccountId: String,
        chargesEnabled: Bool,
        detailsSubmitted: Bool,
        payoutsEnabled: Bool
    ) {
        self.stripeAccountId = stripeAccountId
        self.chargesEnabled = chargesEnabled
        self.detailsSubmitted = detailsSubmitted
        self.payoutsEnabled = payoutsEnabled
    }
}

// MARK: - Stripe Onboarding Link

public struct StripeOnboardingLink: Codable, Sendable, Equatable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}

// MARK: - Stripe Status

public struct StripeStatus: Codable, Sendable, Equatable {
    public let chargesEnabled: Bool
    public let detailsSubmitted: Bool
    public let payoutsEnabled: Bool

    public init(chargesEnabled: Bool, detailsSubmitted: Bool, payoutsEnabled: Bool) {
        self.chargesEnabled = chargesEnabled
        self.detailsSubmitted = detailsSubmitted
        self.payoutsEnabled = payoutsEnabled
    }
}

// MARK: - Stripe Balance

public struct StripeBalanceEntry: Codable, Sendable, Equatable {
    public let amount: Int
    public let currency: String

    public init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}

public struct StripeBalance: Codable, Sendable, Equatable {
    public let available: [StripeBalanceEntry]
    public let pending: [StripeBalanceEntry]

    public init(available: [StripeBalanceEntry], pending: [StripeBalanceEntry]) {
        self.available = available
        self.pending = pending
    }
}

// MARK: - Stripe Dashboard Link

public struct StripeDashboardLink: Codable, Sendable, Equatable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}
