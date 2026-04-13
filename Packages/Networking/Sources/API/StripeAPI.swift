import Foundation

public enum StripeAPI {

    public static func createAccount() -> Endpoint<StripeAccount> {
        .post("/mentors/me/stripe/account", auth: .bearerToken)
    }

    public static func createOnboardingLink() -> Endpoint<StripeOnboardingLink> {
        .post("/mentors/me/stripe/onboarding-link", auth: .bearerToken)
    }

    public static func status() -> Endpoint<StripeStatus> {
        .get("/mentors/me/stripe/status", auth: .bearerToken)
    }
}
