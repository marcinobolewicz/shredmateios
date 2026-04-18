import Foundation
import Observation
import StripePaymentSheet

/// Configures the Stripe SDK and prepares `PaymentSheet` instances.
///
/// This service is the single point of contact with the Stripe iOS SDK.
/// It owns SDK initialization (publishable key) and builds payment sheet
/// configurations from a server-provided `clientSecret`.
@MainActor
@Observable
public final class StripePaymentService {

    private let applePayMerchantId: String?
    private let applePayMerchantCountryCode: String

    // MARK: - Init

    /// Initializes the Stripe SDK with the given publishable key.
    ///
    /// Call this once at app startup (e.g. in `AppSetup.configure()`).
    /// - Parameters:
    ///   - publishableKey: Your Stripe publishable key (`pk_test_…` / `pk_live_…`).
    ///   - applePayMerchantId: Apple Merchant ID (e.g. `merchant.pl.shredmate.app`).
    ///     When `nil` or empty, Apple Pay will not be offered in the PaymentSheet.
    ///   - applePayMerchantCountryCode: ISO country code of the merchant (default `PL`).
    public init(
        publishableKey: String,
        applePayMerchantId: String? = nil,
        applePayMerchantCountryCode: String = "PL"
    ) {
        STPAPIClient.shared.publishableKey = publishableKey
        let trimmed = applePayMerchantId?.trimmingCharacters(in: .whitespaces)
        self.applePayMerchantId = (trimmed?.isEmpty == false) ? trimmed : nil
        self.applePayMerchantCountryCode = applePayMerchantCountryCode
    }

    // MARK: - Payment Sheet

    /// Creates a configured `PaymentSheet` ready to be presented.
    ///
    /// - Parameters:
    ///   - clientSecret: The `client_secret` from a PaymentIntent created on your backend.
    ///   - merchantDisplayName: Name shown on the payment sheet (e.g. "ShredMate").
    ///   - customerId: Optional Stripe Customer ID for saved payment methods.
    ///   - ephemeralKeySecret: Optional ephemeral key secret paired with `customerId`.
    /// - Returns: A `PaymentSheet` configured and ready to present.
    public func makePaymentSheet(
        clientSecret: String,
        merchantDisplayName: String = "ShredMate",
        customerId: String? = nil,
        ephemeralKeySecret: String? = nil
    ) -> PaymentSheet {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = merchantDisplayName
        configuration.allowsDelayedPaymentMethods = false

        if let applePayMerchantId {
            configuration.applePay = .init(
                merchantId: applePayMerchantId,
                merchantCountryCode: applePayMerchantCountryCode
            )
        }

        if let customerId, let ephemeralKeySecret {
            configuration.customer = .init(
                id: customerId,
                ephemeralKeySecret: ephemeralKeySecret
            )
        }

        return PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )
    }

    /// Maps the Stripe SDK's `PaymentSheetResult` to the app's `PaymentResult`.
    public func mapResult(_ sheetResult: PaymentSheetResult) -> PaymentResult {
        switch sheetResult {
        case .completed:
            return .completed
        case .canceled:
            return .canceled
        case .failed(let error):
            return .failed(error.localizedDescription)
        }
    }
}
