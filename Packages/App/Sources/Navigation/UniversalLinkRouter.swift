import Foundation

enum UniversalLinkRouter {

    private static let host = "shredmate.pl"

    /// Attempts to parse a universal link URL into a `DeepLink`.
    ///
    /// Returns `nil` when the URL doesn't match a known path.
    static func deepLink(from url: URL) -> DeepLink? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            components.host == host
        else { return nil }

        switch components.path {
        case "/app/stripe/onboarding/result":
            let status = components.queryItems?
                .first { $0.name == "status" }?.value
            return .stripeOnboardingResult(status: status)
        default:
            return nil
        }
    }
}
