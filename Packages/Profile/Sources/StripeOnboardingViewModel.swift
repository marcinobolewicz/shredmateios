import Foundation
import Observation
import Networking
import UIKit

// MARK: - Return Status

public enum StripeReturnStatus: Sendable, Equatable {
    case success
    case pending
    case restricted

    public init?(rawValue: String?) {
        switch rawValue {
        case "success", "complete": self = .success
        case "pending": self = .pending
        case "restricted": self = .restricted
        default: return nil
        }
    }
}

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
        case loadingBalance
        case openingDashboard
    }

    private(set) var step: Step = .idle
    private(set) var status: StripeStatus?
    private(set) var balance: StripeBalance?
    private(set) var balanceUnavailable: Bool = false
    private(set) var error: String?
    private(set) var returnStatus: StripeReturnStatus?

    var isLoading: Bool {
        switch step {
        case .creatingAccount, .creatingLink, .refreshingStatus, .loadingBalance, .openingDashboard: true
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

    var isReady: Bool {
        isOnboardingComplete && areChargesEnabled && arePayoutsEnabled
    }

    var isOpeningDashboard: Bool {
        step == .openingDashboard
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

        if isReady {
            await loadBalance()
        } else {
            balance = nil
            balanceUnavailable = false
        }
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

        if isReady {
            await loadBalance()
        } else {
            balance = nil
            balanceUnavailable = false
        }
    }

    func loadBalance() async {
        step = .loadingBalance
        error = nil

        do {
            balance = try await stripeService.fetchBalance()
            balanceUnavailable = false
        } catch {
            balance = nil
            balanceUnavailable = true
        }

        step = .idle
    }

    func openDashboard() async {
        step = .openingDashboard
        error = nil

        let dashboardURL: URL
        do {
            let link = try await stripeService.createDashboardLink()
            guard let url = URL(string: link.url) else {
                self.error = StripeStrings.invalidDashboardURL.localized
                step = .idle
                return
            }
            dashboardURL = url
        } catch {
            self.error = StripeStrings.failedDashboardLink(error.localizedDescription)
            step = .idle
            return
        }

        await urlOpener.open(dashboardURL)
        step = .idle
    }

    func handleReturn(status rawStatus: String?) async {
        returnStatus = StripeReturnStatus(rawValue: rawStatus)
        await refreshAfterReturn()
    }

    func clearReturnStatus() {
        returnStatus = nil
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
