import Foundation
import Observation
import Networking
import UIKit

@MainActor
@Observable
public final class StripeOnboardingViewModel {

    // MARK: - State

    enum Step: Equatable {
        case idle
        case creatingAccount
        case creatingLink
        case awaitingReturn
        case refreshingStatus
    }

    private(set) var step: Step = .idle
    private(set) var status: StripeStatus?
    private(set) var error: String?

    var isLoading: Bool {
        switch step {
        case .creatingAccount, .creatingLink, .refreshingStatus: true
        default: false
        }
    }

    var isOnboardingComplete: Bool {
        status?.detailsSubmitted == true
    }

    var arePayoutsEnabled: Bool {
        status?.payoutsEnabled == true
    }

    var areChargesEnabled: Bool {
        status?.chargesEnabled == true
    }

    // MARK: - Dependencies

    private let stripeService: any StripeServiceProtocol
    private let urlOpener: any URLOpening

    // MARK: - Init

    public init(
        stripeService: any StripeServiceProtocol,
        urlOpener: any URLOpening = DefaultURLOpener()
    ) {
        self.stripeService = stripeService
        self.urlOpener = urlOpener
    }

    // MARK: - Actions

    func loadStatus() async {
        step = .refreshingStatus
        error = nil

        do {
            status = try await stripeService.fetchStatus()
        } catch let networkError as NetworkError where networkError.isNotFound {
            status = nil
        } catch {
            self.error = StripeStrings.failedLoadStatus(error.localizedDescription)
        }

        step = .idle
    }

    func startOnboarding() async {
        error = nil

        step = .creatingAccount
        do {
            _ = try await stripeService.createAccount()
        } catch {
            self.error = StripeStrings.failedCreateAccount(error.localizedDescription)
            step = .idle
            return
        }

        step = .creatingLink
        let onboardingURL: URL
        do {
            let link = try await stripeService.createOnboardingLink()
            guard let url = URL(string: link.url) else {
                self.error = StripeStrings.invalidOnboardingURL.localized
                step = .idle
                return
            }
            onboardingURL = url
        } catch {
            self.error = StripeStrings.failedCreateLink(error.localizedDescription)
            step = .idle
            return
        }

        await urlOpener.open(onboardingURL)
        step = .awaitingReturn
    }

    func refreshAfterReturn() async {
        step = .refreshingStatus
        error = nil

        do {
            status = try await stripeService.fetchStatus()
        } catch let networkError as NetworkError where networkError.isNotFound {
            status = nil
        } catch {
            self.error = StripeStrings.failedRefreshStatus(error.localizedDescription)
        }

        step = .idle
    }

    func clearError() {
        error = nil
    }
}

// MARK: - URL Opening Abstraction

public protocol URLOpening: Sendable {
    @MainActor func open(_ url: URL) async
}

public final class DefaultURLOpener: URLOpening, Sendable {
    public init() {}

    @MainActor
    public func open(_ url: URL) async {
        await UIApplication.shared.open(url)
    }
}
