import Foundation

public protocol StripeServiceProtocol: Sendable {
    func createAccount() async throws -> StripeAccount
    func createOnboardingLink() async throws -> StripeOnboardingLink
    func fetchStatus() async throws -> StripeStatus
}

public final class StripeService: StripeServiceProtocol, Sendable {

    private let client: APIClienting

    public init(client: APIClienting) {
        self.client = client
    }

    public func createAccount() async throws -> StripeAccount {
        try await client.send(StripeAPI.createAccount())
    }

    public func createOnboardingLink() async throws -> StripeOnboardingLink {
        try await client.send(StripeAPI.createOnboardingLink())
    }

    public func fetchStatus() async throws -> StripeStatus {
        try await client.send(StripeAPI.status())
    }
}
