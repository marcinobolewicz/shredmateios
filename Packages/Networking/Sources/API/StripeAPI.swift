import Foundation

public enum StripeAPI {

    public static func createAccount() -> Endpoint<StripeAccount> {
        .post("/riders/me/stripe/account", auth: .bearerToken)
    }

    public static func createOnboardingLink() -> Endpoint<StripeOnboardingLink> {
        .post("/riders/me/stripe/onboarding-link", auth: .bearerToken)
    }

    public static func status() -> Endpoint<StripeStatus> {
        .get("/riders/me/stripe/status", auth: .bearerToken)
    }
}
