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
