import Foundation

// MARK: - Stripe Account

public struct StripeAccount: Codable, Sendable, Equatable {
    public let accountId: String

    public init(accountId: String) {
        self.accountId = accountId
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
    public let onboardingCompleted: Bool
    public let payoutsEnabled: Bool

    public init(onboardingCompleted: Bool, payoutsEnabled: Bool) {
        self.onboardingCompleted = onboardingCompleted
        self.payoutsEnabled = payoutsEnabled
    }
}
